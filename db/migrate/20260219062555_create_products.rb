class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.timestamps
      t.string :name
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.integer :stock_quantity
    end
  end
end
