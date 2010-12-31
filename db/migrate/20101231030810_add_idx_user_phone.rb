class AddIdxUserPhone < ActiveRecord::Migration
  def self.up
    add_index :user_phones, :number
  end

  def self.down
    remove_index :user_phones, :number
  end
end
