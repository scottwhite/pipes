DELIMITER ;;
DROP TRIGGER IF EXISTS update_to_dead;

create trigger update_to_dead before update on dids
  for each row begin
  
    set @id = null;
    set @phone= null;
    
    if OLD.usage_state = 0 and NEW.usage_state = 1 then
      select dup.id, up.number
      into @id, @phone
      from dids_user_phones dup
      inner join user_phones up on
      up.id = dup.user_phone_id
      inner join dids on
      dids.id = dup.did_id
      and dids.id = OLD.id
      where dup.expire_state = 1
      order by dup.updated_at desc
      limit 1;
      
      if @id is not NULL then
        update dids_user_phones
        set expire_state = 2
        where id = @id;
        
        insert into dids_last_used
          values(OLD.id, @id, @phone, NOW(), NOW());
          
      end if;
    end if;
  end;
