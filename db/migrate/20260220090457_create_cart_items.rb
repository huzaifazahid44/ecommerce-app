class CreateCartItems < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.timestamps
    end
    add_index :cart_items, [:user_id, :product_id], unique: true
  end
end
