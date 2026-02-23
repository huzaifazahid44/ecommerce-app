require "ostruct"

class CartItemsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  def index
    @items = build_cart_items
  end

  def create
    product = Product.find(params[:product_id])
    qty = params[:quantity].to_i
    qty = 1 if qty <= 0
    allowed_max = [ 5, product.stock_quantity.to_i ].min

    session[:cart] ||= {}
    current = session[:cart][product.id.to_s].to_i
    session[:cart][product.id.to_s] = [ current + qty, allowed_max ].min

    Rails.logger.debug "[DEBUG] Cart after add: #{session[:cart].inspect} (added product_id=#{product.id}, qty=#{qty})"

    @items = build_cart_items
    @product = product
    @current_quantity = session[:cart][product.id.to_s].to_i
    # Broadcast updates to other tabs/windows sharing this session
    begin
      Rails.logger.debug "[DEBUG] Broadcasting Turbo Streams for ADD (cart_stream_name=#{cart_stream_name})"
      Turbo::StreamsChannel.broadcast_replace_to(cart_stream_name, target: "cart_count", partial: "shared/cart_count", locals: { count: cart_total_quantity })
      Turbo::StreamsChannel.broadcast_replace_to(cart_stream_name, target: "cart_dropdown", partial: "shared/cart_dropdown")
      Turbo::StreamsChannel.broadcast_replace_to(cart_stream_name, target: "cart_page", partial: "cart_items/cart_page")
    rescue => e
      Rails.logger.debug "[DEBUG] Turbo broadcast failed: "+e.message
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: products_path, notice: "Added to cart." }
    end
  end

  # DELETE /cart_items (expects product_id param)
  def destroy
    pid = params[:product_id] || params[:id]
    if pid
      session[:cart] ||= {}
      session[:cart].delete(pid.to_s)
    end

    Rails.logger.debug "[DEBUG] Cart after remove: #{session[:cart].inspect} (removed product_id=#{pid})"

    @items = build_cart_items

      # Broadcast the updated cart to other tabs in this session
      begin
        Rails.logger.debug "[DEBUG] Broadcasting Turbo Streams for REMOVE (cart_stream_name=#{cart_stream_name})"
        Turbo::StreamsChannel.broadcast_replace_to(cart_stream_name, target: "cart_count", partial: "shared/cart_count", locals: { count: cart_total_quantity })
        Turbo::StreamsChannel.broadcast_replace_to(cart_stream_name, target: "cart_dropdown", partial: "shared/cart_dropdown")
        Turbo::StreamsChannel.broadcast_replace_to(cart_stream_name, target: "cart_page", partial: "cart_items/cart_page")
      rescue => e
        Rails.logger.debug "[DEBUG] Turbo broadcast failed: "+e.message
      end

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to cart_path, notice: "Removed from cart." }
      end
  end

  private

  def build_cart_items
    cart_hash = session[:cart] || {}
    products = Product.where(id: cart_hash.keys)
    products.map do |p|
      OpenStruct.new(product: p, quantity: cart_hash[p.id.to_s].to_i)
    end
  end
end
