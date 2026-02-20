class AddCartRefAndQuantityToCartItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :cart_items, :cart, foreign_key: true, index: true
    add_column :cart_items, :quantity, :integer, null: false, default: 1

    # add unique index per cart+product to prevent duplicate rows for same cart/product
    add_index :cart_items, [:cart_id, :product_id], unique: true
  end
end
