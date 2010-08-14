class UserPhones < ActiveRecord::Migration
  def self.up
    create_table :user_phones do|t|
      t.integer :user_id, null: false
      t.string :number, limit: 100, null: false
      t.active :boolean, default: false, null: false
      t.timestamps
    end
    
    connection.execute("alter table user_phones add constraint foreign key (user_id) references users(id)")
    
  end

  def self.down
    
    drop_table :user_phones
  end
end
