class Product < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :in_stock, -> { where('stock_quantity > ?', 0) }
  scope :out_of_stock, -> { where(stock_quantity: 0) }

  after_create_commit  -> { broadcast_prepend_to "products", target: "products_grid" }
  after_update_commit  -> { broadcast_replace_to "products" }
  after_destroy_commit -> { broadcast_remove_to "products" }

  def available?
    stock_quantity > 0
  end

  def formatted_price
    "$#{format('%.2f', price)}"
  end
end
