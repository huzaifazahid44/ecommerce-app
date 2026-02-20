Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "products#index"

  # Checkout routes
  post '/checkout', to: 'checkouts#create'
  get '/checkout/success', to: 'checkouts#success', as: :checkout_success
  # Allow deleting by product_id via collection delete
  delete '/cart_items', to: 'cart_items#destroy'
  # Cart routes
  get "cart" => "cart_items#index", as: :cart
  resources :cart_items, only: [:create, :destroy]
  
  # Authentication routes
  #products routes
  resources :products
  
  # Authentication routes
  get "login" => "sessions#new", as: :login
  post "login" => "sessions#create"
  delete "logout" => "sessions#destroy", as: :logout
  
  # User registration routes
  get "signup" => "users#new", as: :signup
  post "signup" => "users#create"
end
