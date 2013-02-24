class AddSourceToProducts < ActiveRecord::Migration
  def self.up
    remove_column :products, :ios_product_id
    add_column :products, :source, :string
    add_column :products, :source_product_id, :string
    add_column :products, :product_type, :string
  end

  def self.down
    add_column :products, :ios_product_id, :string
    remove_column :products, :source
    remove_column :products, :source_product_id
    remove_column :products, :product_type
  end
end
