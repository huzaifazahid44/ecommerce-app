class MakeCartItemUserOptional < ActiveRecord::Migration[8.1]
  def change
    # Allow cart_items.user_id to be null so guests can have cart_items persisted without a user
    change_column_null :cart_items, :user_id, true
  end
end
