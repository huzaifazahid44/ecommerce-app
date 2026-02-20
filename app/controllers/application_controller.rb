class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
    helper_method :current_user
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = User.find_by(id: session[:user_id])
  end

    helper_method :current_session_cart, :cart_total_quantity

    helper_method :cart_stream_name

    require 'securerandom'

    # per-session stream name so multiple browser tabs/windows for the same session
    # can subscribe and receive real-time cart updates
    def cart_stream_name
      session[:cart_stream_id] ||= SecureRandom.hex(8)
      "cart_#{session[:cart_stream_id]}"
    end

    # session-based cart hash: { product_id => quantity }
    def current_session_cart
      session[:cart] ||= {}
    end

    # total quantity across session cart or persisted cart
    def cart_total_quantity
      # prefer persisted cart if present in session
      if session[:cart_token]
        cart = Cart.find_by(token: session[:cart_token])
        return cart ? cart.cart_items.sum(:quantity) : 0
      end

      # if user has persistent cart items (legacy), sum them
      if current_user && current_user.respond_to?(:cart_items)
        return current_user.cart_items.sum(:quantity)
      end

      # fallback to session cart sum
      current_session_cart.values.map(&:to_i).sum
    end

  helper_method :logged_in?
  def logged_in?
    current_user.present?
  end

  def require_user
    unless logged_in?
      flash[:alert] = "You must be logged in to perform that action."
      redirect_to login_path
    end
  end
end
