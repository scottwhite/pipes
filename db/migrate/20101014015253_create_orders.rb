class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :user_id, null: false
      t.integer :status, null: false
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.string :gateway_trans_id, null: true
      t.timestamps
    end
    
    connection.execute("alter table user_phones add constraint foreign key (user_id) references users(id)")
  end

  def self.down
    drop_table :orders
  end
end
