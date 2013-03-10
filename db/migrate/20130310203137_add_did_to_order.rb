class AddDidToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :pipes_number, :string
  end

  def self.down
    remove_column :orders, :pipes_number
  end
end
