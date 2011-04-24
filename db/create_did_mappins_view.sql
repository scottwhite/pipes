DELIMITER ;;
DROP VIEW IF EXISTS did_mappings;

CREATE VIEW `did_mappings` AS 
    select `d`.`id` as `did_id`,`d`.`phone_number` AS `pipes_number`,
    `d`.`provider_id`, `d`.`provider`,
    `up`.`number` AS `user_number`,
    `dup`.`current_usage` AS `current_usage`,
    (dup.time_allotted - current_usage) as 'time_left'
    from `dids` `d` 
    join `dids_user_phones` `dup` on `dup`.`did_id` = `d`.`id`
    and dup.expire_state = 0 and dup.expiration_date >= NOW()
    join `user_phones` `up` on `up`.`id` = `dup`.`user_phone_id`
    where d.usage_state = 2;