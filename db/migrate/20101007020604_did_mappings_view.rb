class DidMappingsView < ActiveRecord::Migration
  def self.up
    connection.execute(%Q{CREATE VIEW `did_mappings` AS 
        select `d`.`phone_number` AS `phone_number`,
        `up`.`number` AS `number`,
        `dup`.`current_usage` AS `current_usage`,
        (1200 - current_usage) as 'time_left'
        from `dids` `d` 
        join `dids_user_phones` `dup` on `dup`.`did_id` = `d`.`id`
        join `user_phones` `up` on `up`.`id` = `dup`.`user_phone_id`
        where usage_state = 2})
  end

  def self.down
    connection.execute("drop view did_mappings")
  end
end
