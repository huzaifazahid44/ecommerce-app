require "stripe"

class CheckoutsController < ApplicationController
  # POST /checkout
  def create
    # Build cart from session (session[:cart] expected as { product_id => quantity })
    session_cart = session[:cart] || {}
    if session_cart.empty?
      redirect_to cart_path, alert: "Your cart is empty." and return
    end

    # Ensure Stripe is configured (assign from ENV if initializer didn't)
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"] if Stripe.respond_to?(:api_key) && Stripe.api_key.blank?
    if Stripe.respond_to?(:api_key) && Stripe.api_key.blank?
      redirect_to cart_path, alert: "Stripe not configured (STRIPE_SECRET_KEY)." and return
    end

    # Create a persisted Cart record to keep order history
    cart = Cart.create!

    line_items = []

    session_cart.each do |product_id_str, qty|
      product_id = product_id_str.to_i
      product = Product.find_by(id: product_id)
      next unless product

      allowed_qty = [ qty.to_i, 5, product.stock_quantity.to_i ].min
      next if allowed_qty <= 0

      cart.cart_items.create!(product: product, quantity: allowed_qty)

      line_items << {
        price_data: {
          currency: "usd",
          product_data: { name: product.name },
          unit_amount: (product.price.to_f * 100).to_i
        },
        quantity: allowed_qty
      }
    end

    if line_items.empty?
      cart.destroy
      redirect_to cart_path, alert: "No valid products in cart." and return
    end

    # Ensure Stripe is configured
    if Stripe.respond_to?(:api_key) && Stripe.api_key.blank?
      cart.destroy
      redirect_to cart_path, alert: "Stripe not configured (STRIPE_SECRET_KEY)." and return
    end

    begin
      checkout_session = Stripe::Checkout::Session.create(
        payment_method_types: [ "card" ],
        line_items: line_items,
        mode: "payment",
        success_url: checkout_success_url + "?cart_token=#{cart.token}&session_id={CHECKOUT_SESSION_ID}",
        cancel_url: cart_url
      )
    rescue ::Stripe::StripeError => e
      cart.destroy
      Rails.logger.error "Stripe error creating checkout session: #{e.message}"
      redirect_to cart_path, alert: "Could not create Stripe Checkout session: #{e.message}" and return
    end

    # Clear the session cart (we now have the persisted cart)
    session.delete(:cart)
    # remember the persisted cart token so we can show it later if needed
    session[:cart_token] = cart.token

    # For Turbo stream requests, return a turbo-stream that triggers a client-side redirect.
    if request.format.turbo_stream?
      render plain: <<~TS, content_type: "text/vnd.turbo-stream.html"
        <turbo-stream action="replace" target="flash">
          <template>
            <div class=\"sr-only\">Redirecting...</div>
          </template>
        </turbo-stream>
        <turbo-stream action="update" target="_top">
          <template>
            <script>window.location = #{checkout_session.url.to_json};</script>
          </template>
        </turbo-stream>
      TS
    else
      redirect_to checkout_session.url, allow_other_host: true
    end
  end

  def success
    token = params[:cart_token]
    @cart = Cart.find_by(token: token)
    if @cart
      # mark as paid and decrement stock
      ActiveRecord::Base.transaction do
        @cart.cart_items.each do |ci|
          product = ci.product
          next unless product
          product.stock_quantity = [ product.stock_quantity.to_i - ci.quantity.to_i, 0 ].max
          product.save!
        end
        @cart.update!(paid: true)
      end
    end
  end
end
