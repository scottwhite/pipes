class AddTimeAllotted < ActiveRecord::Migration
  def self.up
    add_column :dids_user_phones, :time_allotted, :int, default: 1200, null:false
    connection.execute("drop view did_mappings")
    
    connection.execute(%Q{CREATE VIEW `did_mappings` AS 
        select `d`.`phone_number` AS `phone_number`,
        `up`.`number` AS `number`,
        `dup`.`current_usage` AS `current_usage`,
        (dup.time_allotted - current_usage) as 'time_left'
        from `dids` `d` 
        join `dids_user_phones` `dup` on `dup`.`did_id` = `d`.`id`
        and dup.expired = 0
        join `user_phones` `up` on `up`.`id` = `dup`.`user_phone_id`
        where usage_state = 2})
    
  end

  def self.down
    remove_column :dids_user_phones, :time_allotted
  end
end
