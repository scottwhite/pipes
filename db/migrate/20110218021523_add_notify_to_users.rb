class AddNotifyToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :receive_notifications, :boolean, default: true, null: false
  end

  def self.down
    remove_column :users, :notify
  end
end
