class AddCityStateToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :state, :string
    add_column :orders, :city, :string
  end

  def self.down
    remove_column :orders, :state
    remove_column :orders, :city
  end
end
