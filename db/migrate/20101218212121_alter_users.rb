class AlterUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :email, :string, :limit => 100, :null=>false
    remove_index :users, :login
    change_column :users, :login, :string, :limit => 40, :null=>true
    add_index :users, :email, :unique => true
  end

  def self.down
  end
end
