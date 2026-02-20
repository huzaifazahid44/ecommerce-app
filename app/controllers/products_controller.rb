class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, only: [:new, :create, :edit, :update, :destroy]

  def index
    @products = Product.with_attached_image.order(created_at: :desc)
    @cart_items = current_user&.cart_items&.pluck(:product_id) || []
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @product, notice: "Product was successfully created." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html         { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: "Product was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @product.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to products_path, notice: "Product was successfully deleted." }
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock_quantity, :image)
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, flash: { alert: "You must be an admin to perform this action." }
    end
  end
end 