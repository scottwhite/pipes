class AddUserPhoneIdToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :user_phone_id, :integer
    connection.execute("alter table orders add constraint foreign key (user_phone_id) references user_phones(id)")
  end

  def self.down
    drop_column :orders, :user_phone_id
  end
end
