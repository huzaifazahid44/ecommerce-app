class CartItem < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :cart, optional: true
  belongs_to :product

  validates :product_id, uniqueness: { scope: :cart_id }, if: -> { cart_id.present? }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
