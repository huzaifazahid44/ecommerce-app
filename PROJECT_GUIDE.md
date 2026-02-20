# E-Commerce App with Turbo Frames & Turbo Streams - Project Guide

## 📋 Project Overview

A minimal e-commerce application built with Ruby on Rails to explore and demonstrate:
- **Turbo Frames** for seamless page updates
- **Turbo Streams** for real-time cart functionality
- **Tailwind CSS** for modern UI
- **Stripe Checkout** for payment processing

### Core Features
1. **Super Admin Panel** - Full CRUD for product management
2. **User Shopping** - Browse products and manage cart
3. **Real-time Cart** - Add/remove items without page reload (Turbo Streams)
4. **Checkout** - Stripe integration for payments

---

## 🛠 Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Ruby on Rails 8.0+ |
| Frontend | Hotwire (Turbo + Stimulus) |
| Styling | Tailwind CSS |
| Database | SQLite (dev), PostgreSQL (production) |
| Payments | Stripe Checkout |
| Authentication | Rails built-in `has_secure_password` |

---

## 📦 Required Gems

### Gemfile Dependencies

```ruby
# Core Rails gems (already included)
gem "rails", "~> 8.0"
gem "propshaft"  # Asset pipeline
gem "sqlite3"    # Database (development)
gem "puma"       # Web server

# Hotwire (Turbo + Stimulus)
gem "turbo-rails"
gem "stimulus-rails"

# Tailwind CSS
gem "tailwindcss-rails"

# Stripe Integration
gem "stripe"

# Authentication
gem "bcrypt", "~> 3.1.7"  # For has_secure_password

# File Upload (for product images)
gem "image_processing", "~> 1.2"  # ActiveStorage variants

# Development & Testing
group :development, :test do
  gem "debug"
  gem "faker"  # For seed data
end

group :development do
  gem "web-console"
end
```

### Installation Commands
```bash
# Add Tailwind CSS
./bin/rails tailwindcss:install

# Install Stripe gem
bundle add stripe

# Install Faker for seed data
bundle add faker --group development

# Install image processing
bundle add image_processing
```

---

## 🗄 Database Schema & Models

### 1. **User Model** (Authentication)

**Attributes:**
- `email` (string, unique, indexed)
- `password_digest` (string)
- `role` (string) - values: 'user', 'admin'
- `name` (string)

**Associations:**
- `has_many :cart_items`
- `has_many :orders`

**Validations:**
- Email presence, uniqueness, format
- Password presence (min 6 characters)
- Role inclusion in ['user', 'admin']

---

### 2. **Product Model**

**Attributes:**
- `name` (string)
- `description` (text)
- `price` (decimal, precision: 10, scale: 2)
- `stock_quantity` (integer, default: 0)

**Associations:**
- `has_one_attached :image` (ActiveStorage)
- `has_many :cart_items`
- `has_many :order_items`

**Validations:**
- Name presence
- Price presence, numericality (>= 0)
- Stock quantity numericality (>= 0)

**Scopes:**
- `scope :in_stock, -> { where('stock_quantity > ?', 0) }`

---

### 3. **CartItem Model** (Session-based or User-based)

**Attributes:**
- `user_id` (integer, foreign key, optional for guest users)
- `session_id` (string, for guest carts)
- `product_id` (integer, foreign key)
- `quantity` (integer, default: 1)

**Associations:**
- `belongs_to :user, optional: true`
- `belongs_to :product`

**Validations:**
- Product presence
- Quantity presence, numericality (> 0)

**Methods:**
- `total_price` - calculates `quantity * product.price`

---

### 4. **Order Model**

**Attributes:**
- `user_id` (integer, foreign key, optional)
- `email` (string)
- `total_amount` (decimal, precision: 10, scale: 2)
- `stripe_checkout_session_id` (string)
- `status` (string) - values: 'pending', 'paid', 'cancelled'
- `stripe_payment_intent_id` (string)

**Associations:**
- `belongs_to :user, optional: true`
- `has_many :order_items, dependent: :destroy`

**Validations:**
- Email presence and format
- Total amount presence, numericality (>= 0)
- Status inclusion

---

### 5. **OrderItem Model**

**Attributes:**
- `order_id` (integer, foreign key)
- `product_id` (integer, foreign key)
- `quantity` (integer)
- `price_at_purchase` (decimal, precision: 10, scale: 2)

**Associations:**
- `belongs_to :order`
- `belongs_to :product`

**Validations:**
- All fields presence
- Quantity and price numericality

---

## 🎯 Controllers Structure

### 1. **SessionsController**
```
Actions: new, create, destroy
Purpose: User login/logout
Turbo: Standard form submissions
```

### 2. **Admin::ProductsController**
```
Namespace: Admin
Actions: index, new, create, edit, update, destroy
Purpose: Product CRUD for admin
Turbo Frames: 
  - Product form in modal/slide-over
  - Inline editing
Before Action: require_admin
```

### 3. **ProductsController**
```
Actions: index, show
Purpose: Public product browsing
Turbo Frames: Product quick view
```

### 4. **CartItemsController**
```
Actions: create, update, destroy, index
Purpose: Cart management
Turbo Streams: 
  - Add to cart → update cart count, flash message
  - Update quantity → update line item, cart total
  - Remove item → remove line item, update total
```

### 5. **CheckoutController**
```
Actions: new, create, success, cancel
Purpose: Stripe checkout flow
Methods:
  - create → create Stripe Session, redirect
  - success → verify payment, create order
```

### 6. **OrdersController**
```
Actions: index, show
Purpose: Order history and details
```

---

## 🎨 Views & Templates Structure

### Layout Structure
```
app/views/
├── layouts/
│   ├── application.html.erb          # Main layout
│   └── admin.html.erb                 # Admin layout (optional)
│
├── sessions/
│   └── new.html.erb                   # Login form
│
├── products/
│   ├── index.html.erb                 # Product grid
│   └── show.html.erb                  # Product details (Turbo Frame)
│
├── admin/
│   └── products/
│       ├── index.html.erb             # Admin product list
│       ├── _form.html.erb             # Product form (Turbo Frame)
│       ├── new.html.erb               # New product page
│       ├── edit.html.erb              # Edit product page
│       └── _product.html.erb          # Product partial
│
├── cart_items/
│   ├── index.html.erb                 # Cart page
│   └── _cart_item.html.erb            # Line item partial (Turbo Frame)
│
├── checkout/
│   ├── new.html.erb                   # Pre-checkout review
│   └── success.html.erb               # Success page
│
├── orders/
│   ├── index.html.erb                 # Order history
│   └── show.html.erb                  # Order details
│
└── shared/
    ├── _header.html.erb               # Navigation with cart count
    ├── _flash.html.erb                # Flash messages (Turbo Stream target)
    └── _cart_summary.html.erb         # Cart sidebar/dropdown
```

---

## ⚡ Turbo Implementation Guide

### Turbo Frames Usage

#### 1. **Product Quick View**
```erb
<!-- products/index.html.erb -->
<turbo-frame id="product_modal">
  <!-- Modal content loads here -->
</turbo-frame>

<!-- products/_product.html.erb -->
<a href="<%= product_path(product) %>" data-turbo-frame="product_modal">
  Quick View
</a>

<!-- products/show.html.erb -->
<turbo-frame id="product_modal">
  <!-- Product details content -->
</turbo-frame>
```

#### 2. **Inline Product Editing (Admin)**
```erb
<!-- admin/products/index.html.erb -->
<%= turbo_frame_tag "product_#{product.id}" do %>
  <%= render product %>
<% end %>

<!-- admin/products/edit.html.erb -->
<%= turbo_frame_tag "product_#{@product.id}" do %>
  <%= render "form", product: @product %>
<% end %>
```

### Turbo Streams Usage

#### 1. **Add to Cart**
```ruby
# cart_items_controller.rb
def create
  @cart_item = current_cart.cart_items.build(cart_item_params)
  
  if @cart_item.save
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("cart_count", partial: "shared/cart_count"),
          turbo_stream.prepend("flash_messages", partial: "shared/flash", 
            locals: { message: "Added to cart!", type: "success" })
        ]
      end
      format.html { redirect_to products_path }
    end
  end
end
```

#### 2. **Update Cart Item Quantity**
```ruby
def update
  @cart_item = CartItem.find(params[:id])
  
  if @cart_item.update(cart_item_params)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("cart_item_#{@cart_item.id}", 
            partial: "cart_items/cart_item", locals: { cart_item: @cart_item }),
          turbo_stream.update("cart_total", partial: "cart_items/total")
        ]
      end
    end
  end
end
```

#### 3. **Remove from Cart**
```ruby
def destroy
  @cart_item = CartItem.find(params[:id])
  @cart_item.destroy
  
  respond_to do |format|
    format.turbo_stream do
      render turbo_stream: [
        turbo_stream.remove("cart_item_#{@cart_item.id}"),
        turbo_stream.update("cart_count", partial: "shared/cart_count"),
        turbo_stream.update("cart_total", partial: "cart_items/total")
      ]
    end
  end
end
```

---

## 💳 Stripe Integration

### Setup

1. **Get Stripe Keys**
   - Sign up at [stripe.com](https://stripe.com)
   - Get test API keys from Dashboard
   - Store in Rails credentials

2. **Configure Credentials**
```bash
EDITOR="code --wait" rails credentials:edit
```

Add:
```yaml
stripe:
  publishable_key: pk_test_xxxxx
  secret_key: sk_test_xxxxx
  webhook_secret: whsec_xxxxx  # For webhooks (optional)
```

3. **Initialize Stripe**
```ruby
# config/initializers/stripe.rb
Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
```

### Checkout Flow

#### 1. **Create Checkout Session**
```ruby
# checkout_controller.rb
def create
  @cart_items = current_cart.cart_items.includes(:product)
  
  line_items = @cart_items.map do |item|
    {
      price_data: {
        currency: 'usd',
        product_data: {
          name: item.product.name,
          description: item.product.description,
        },
        unit_amount: (item.product.price * 100).to_i, # Convert to cents
      },
      quantity: item.quantity,
    }
  end
  
  session = Stripe::Checkout::Session.create(
    mode: 'payment',
    line_items: line_items,
    success_url: checkout_success_url + '?session_id={CHECKOUT_SESSION_ID}',
    cancel_url: checkout_cancel_url,
    customer_email: current_user&.email,
  )
  
  redirect_to session.url, allow_other_host: true
end
```

#### 2. **Handle Success**
```ruby
def success
  session_id = params[:session_id]
  session = Stripe::Checkout::Session.retrieve(session_id)
  
  if session.payment_status == 'paid'
    # Create order
    @order = Order.create!(
      user: current_user,
      email: session.customer_details.email,
      total_amount: session.amount_total / 100.0,
      stripe_checkout_session_id: session_id,
      stripe_payment_intent_id: session.payment_intent,
      status: 'paid'
    )
    
    # Create order items from cart
    current_cart.cart_items.each do |cart_item|
      @order.order_items.create!(
        product: cart_item.product,
        quantity: cart_item.quantity,
        price_at_purchase: cart_item.product.price
      )
    end
    
    # Clear cart
    current_cart.cart_items.destroy_all
  end
end
```

### Test Cards
```
Success: 4242 4242 4242 4242
Decline: 4000 0000 0000 0002
3D Secure: 4000 0025 0000 3155

Use any future expiry date and any 3-digit CVC
```

---

## 🎨 Tailwind CSS Implementation

### Configuration

Already set up in Rails 8. Key files:
- `app/assets/stylesheets/application.tailwind.css`
- `config/tailwind.config.js`

### UI Components Needed

1. **Navigation Bar**
   - Logo
   - Product link
   - Cart icon with count badge
   - Login/Logout

2. **Product Grid** (from Tailwind UI reference)
   - Responsive grid (1-2-3-4 columns)
   - Product cards with image, name, price
   - Quick view button
   - Add to cart button

3. **Shopping Cart**
   - Slide-over panel or dedicated page
   - Line items with quantity selectors
   - Remove button
   - Total calculation
   - Checkout button

4. **Admin Panel**
   - Table layout for products
   - Action buttons (Edit, Delete)
   - Modal/slide-over for forms

5. **Forms**
   - Input fields styled
   - Error states
   - Submit buttons

---

## 🗺 Implementation Roadmap

### Phase 1: Foundation (Day 1)
1. ✅ Rails app already created
2. Install required gems
3. Install Tailwind CSS
4. Set up authentication (User model + sessions)
5. Create basic layout with navigation

### Phase 2: Product Management (Day 2)
1. Generate Product model and migration
2. Set up ActiveStorage for images
3. Create Admin::ProductsController
4. Build admin CRUD views
5. Implement Turbo Frames for inline editing
6. Seed sample products with Faker

### Phase 3: Shopping Experience (Day 3)
1. Build public product listing page
2. Create product detail view
3. Implement Turbo Frame for quick view
4. Style with Tailwind (product grid)

### Phase 4: Cart & Turbo Streams (Day 4)
1. Generate CartItem model
2. Create CartItemsController
3. Implement "Add to Cart" with Turbo Stream
4. Build cart page with line items
5. Add quantity update with Turbo Stream
6. Add remove item with Turbo Stream
7. Real-time cart count in header

### Phase 5: Stripe Integration (Day 5)
1. Set up Stripe account and credentials
2. Create CheckoutController
3. Implement Stripe Checkout Session
4. Build checkout review page
5. Handle success/cancel callbacks
6. Generate Order and OrderItem models
7. Create orders after successful payment

### Phase 6: Polish (Day 6)
1. Add order history page
2. Improve error handling
3. Add loading states
4. Final UI polish with Tailwind
5. Test complete flow
6. Add flash messages

---

## 🚀 Getting Started - Step by Step

### Step 1: Install Dependencies

```bash
cd /home/lenovo/ecommerce-app

# Update Gemfile with required gems
bundle add turbo-rails stimulus-rails tailwindcss-rails stripe bcrypt image_processing
bundle add faker --group development

# Install Tailwind
./bin/rails tailwindcss:install

# Run bundle install
bundle install
```

### Step 2: Generate Models

```bash
# User model
rails g model User email:string password_digest:string role:string name:string

# Product model
rails g model Product name:string description:text price:decimal{10,2} stock_quantity:integer sku:string:uniq active:boolean

# CartItem model
rails g model CartItem user:references session_id:string product:references quantity:integer

# Order model
rails g model Order user:references email:string total_amount:decimal{10,2} stripe_checkout_session_id:string status:string stripe_payment_intent_id:string

# OrderItem model
rails g model OrderItem order:references product:references quantity:integer price_at_purchase:decimal{10,2}

# Run migrations
rails db:migrate
```

### Step 3: Set Up ActiveStorage

```bash
rails active_storage:install
rails db:migrate
```

### Step 4: Configure Stripe

```bash
# Edit credentials
EDITOR="code --wait" rails credentials:edit
```

Add Stripe keys, then create initializer.

### Step 5: Generate Controllers

```bash
# Sessions
rails g controller Sessions new create destroy

# Products (public)
rails g controller Products index show

# Admin Products
rails g controller Admin::Products index new create edit update destroy

# Cart Items
rails g controller CartItems index create update destroy

# Checkout
rails g controller Checkout new create success cancel

# Orders
rails g controller Orders index show
```

### Step 6: Configure Routes

Edit `config/routes.rb` with RESTful routes for all resources.

### Step 7: Build Views

Start with layouts, then build each view following the structure above.

### Step 8: Implement Authentication

Add `ApplicationController` helper methods for authentication and authorization.

### Step 9: Add Turbo Functionality

Implement Turbo Frames and Streams as documented above.

### Step 10: Test & Iterate

Test the complete flow from product creation to checkout.

---

## 📝 Key Files Reference

### Routes Example
```ruby
Rails.application.routes.draw do
  root "products#index"
  
  resources :sessions, only: [:new, :create, :destroy]
  resources :products, only: [:index, :show]
  resources :cart_items, only: [:index, :create, :update, :destroy]
  resources :orders, only: [:index, :show]
  
  namespace :admin do
    resources :products
  end
  
  get 'checkout', to: 'checkout#new'
  post 'checkout', to: 'checkout#create'
  get 'checkout/success', to: 'checkout#success'
  get 'checkout/cancel', to: 'checkout#cancel'
  
  get 'login', to: 'sessions#new'
  delete 'logout', to: 'sessions#destroy'
end
```

### Application Controller Helpers
```ruby
class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :current_cart
  
  private
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    current_user.present?
  end
  
  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Please log in"
    end
  end
  
  def require_admin
    unless current_user&.role == 'admin'
      redirect_to root_path, alert: "Access denied"
    end
  end
  
  def current_cart
    if logged_in?
      current_user
    else
      session[:cart_id] ||= SecureRandom.uuid
      @current_cart ||= OpenStruct.new(
        cart_items: CartItem.where(session_id: session[:cart_id])
      )
    end
  end
end
```

---

## 🧪 Seed Data

```ruby
# db/seeds.rb
require 'faker'

# Create admin user
User.create!(
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password',
  role: 'admin',
  name: 'Admin User'
)

# Create regular user
User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password',
  role: 'user',
  name: 'Test User'
)

# Create 20 products
20.times do
  Product.create!(
    name: Faker::Commerce.product_name,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    price: Faker::Commerce.price(range: 10.0..500.0),
    stock_quantity: rand(0..100),
    sku: Faker::Barcode.ean,
    active: true
  )
end

puts "✅ Created #{User.count} users"
puts "✅ Created #{Product.count} products"
```

---

## 🔍 Testing Guide

### Manual Testing Checklist

**Admin Flow:**
- [ ] Login as admin
- [ ] Create new product with image
- [ ] Edit product inline (Turbo Frame)
- [ ] Delete product
- [ ] Verify Turbo Frame updates without page reload

**User Flow:**
- [ ] Browse products
- [ ] Quick view product (Turbo Frame)
- [ ] Add to cart (verify Turbo Stream updates cart count)
- [ ] Update quantity in cart (verify Turbo Stream updates line item)
- [ ] Remove item from cart (verify Turbo Stream removes item)
- [ ] Proceed to checkout
- [ ] Complete Stripe payment with test card
- [ ] Verify order created
- [ ] View order history

**Guest Flow:**
- [ ] Add products to cart without login
- [ ] Checkout as guest
- [ ] Complete payment

---

## 🎯 Learning Objectives

By completing this project, you will learn:

1. **Turbo Frames**
   - Lazy loading content
   - Inline editing without page navigation
   - Modal/slide-over patterns
   
2. **Turbo Streams**
   - Real-time DOM updates
   - Broadcasting multiple changes
   - Handling create/update/delete operations
   
3. **Stripe Integration**
   - Checkout Session API
   - Webhook handling (optional)
   - Test mode usage
   
4. **Rails Patterns**
   - Concerns for shared logic
   - Partials for reusable views
   - Service objects for complex operations

---

## 📚 Resources

- [Turbo Handbook](https://turbo.hotwired.dev/)
- [Stimulus Handbook](https://stimulus.hotwired.dev/)
- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [Stripe Checkout Docs](https://stripe.com/docs/checkout)
- [Rails Guides](https://guides.rubyonrails.org/)
- [Tailwind UI E-commerce Examples](https://tailwindcss.com/plus/ui-blocks/ecommerce)

---

## 🎬 Next Steps

1. **Review this guide** - Familiarize yourself with the architecture
2. **Install dependencies** - Run bundle commands
3. **Generate models** - Create database schema
4. **Start with authentication** - Build login system
5. **Build admin panel** - Product CRUD first
6. **Add public views** - Product listing
7. **Implement cart** - Focus on Turbo Streams
8. **Integrate Stripe** - Checkout flow
9. **Polish UI** - Tailwind styling
10. **Test thoroughly** - Complete flow

---

**Ready to start? Let me know which phase you'd like to begin with!** 🚀
