class DidsUserPhones < ActiveRecord::Migration
  def self.up
    create_table :dids_user_phones do|t|
      t.integer :did_id,null: false
      t.integer :user_phone_id, null: false
      t.integer :current_usage, default: 0, null: false
      t.active :boolean, default: true, null: false
      t.timestamps
    end
    
    connection.execute("alter table dids_user_phones add constraint foreign key (user_phone_id) references user_phones(id)")
    connection.execute("alter table dids_user_phones add constraint foreign key (did_id) references dids(id)")
  end

  def self.down
    drop table :dids_user_phones
  end
end
