class Product < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scope for available products (in stock)
  scope :in_stock, -> { where("stock_quantity > ?", 0) }
  scope :out_of_stock, -> { where(stock_quantity: 0) }

  # Helper method to check if product is available
  def available?
    stock_quantity > 0
  end

  # Format price for display
  def formatted_price
    "$#{format('%.2f', price)}"
  end
end
