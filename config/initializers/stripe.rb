# Configure Stripe with the secret key from environment.
# Requires: set STRIPE_SECRET_KEY in your environment (e.g. in .env or your process manager).
begin
  require 'stripe'
  Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY', nil)

  if Stripe.api_key.blank?
    Rails.logger.warn "Stripe.secret key not set (STRIPE_SECRET_KEY). Checkout will fail until configured."
  else
    Rails.logger.info "Stripe configured."
  end
rescue LoadError
  Rails.logger.warn "Stripe gem not available. Run `bundle install` to install it."
end
