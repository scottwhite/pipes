DELIMITER ;;
DROP VIEW IF EXISTS deny_numbers;

CREATE VIEW `deny_numbers` AS 
  select src,dst,calldate,dup.expiration_date from cdr c
  inner join dids d
  on d.phone_number = c.dst
  inner join dids_user_phones dup
  on dup.did_id = d.id
  and dup.expire_state = 2
  and date_add(dup.expiration_date, INTERVAL 3 WEEK) > NOW();