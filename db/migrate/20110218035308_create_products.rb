class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :name, null: false
      t.decimal :price, precision: 8, scale: 2, null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end
    
    add_column :orders, :product_id, :integer, null: true
    
    self.execute("alter table dids_user_phones change column expired expire_state tinyint default 0 not null")
    
    add_column :dids_user_phones, :expiration_date, :datetime, null: true
  end

  def self.down
    remove_column :orders, :product_id
    drop_table :products
  end
end
