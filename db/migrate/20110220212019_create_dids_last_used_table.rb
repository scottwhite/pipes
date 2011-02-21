class CreateDidsLastUsedTable < ActiveRecord::Migration
  def self.up
    connection.execute(%Q{CREATE TABLE `dids_last_used` (
      did_id  int unsigned not null,
      dids_user_phone_id  int unsigned not null,
      `number` varchar(100) NOT NULL,
      `created_at` datetime NOT NULL default '0000-00-00 00:00:00',
      `updated_at` datetime NOT NULL default '0000-00-00 00:00:00',
      PRIMARY KEY (did_id)
    )})
    
    add_column :call_queue, :dids_user_phone_id, :integer
    
  end

  def self.down
    drop_table :dids_last_used
  end
end
