class AddAppPurchaseToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :ios_product_id, :string
    add_column :products, :requires_existing, :boolean
  end

  def self.down
    remove_column :products, :ios_product_id
    remove_column :products, :requires_existing
  end
end
