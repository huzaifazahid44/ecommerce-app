class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, only: [:new, :create, :edit, :update, :destroy]

  def index
    @products = Product.with_attached_image.order(created_at: :desc)
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to @product, notice: "Product was successfully created."
    else
      render :new, status: :unprocessable_entity
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
    redirect_to products_path, notice: "Product was successfully deleted."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock_quantity)
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, flash: { alert: "You must be an admin to perform this action." }
    end
  end
end 