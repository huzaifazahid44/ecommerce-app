Rails.application.config.session_store :cookie_store, key: "_ecommerce_app_session"
Rails.application.config.middleware.use ActionDispatch::Cookies
Rails.application.config.middleware.use ActionDispatch::Session::CookieStore, key: "_ecommerce_app_session"
