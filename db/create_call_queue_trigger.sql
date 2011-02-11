DELIMITER ;;
DROP TRIGGER IF EXISTS insert_call_queue;

create trigger insert_call_queue after insert on cdr
  for each row begin
  
    set @email = null;
    set @start_date = null;
    set @time_left = null;
    set @source = null;
    set @expired = null;
    set @queue_type = null;
    
    if NEW.lastapp = 'Hangup' then
      set @source = NEW.src;
    else
      set @source = NEW.userfield;
    end if;
    
    select (time_allotted - current_usage) as time_left, dids_user_phones.user_phone_id, dids_user_phones.created_at, dids_user_phones.expired
    into @time_left, @user_phone_id, @start_date, @expired
    from dids_user_phones
    inner join dids on
    dids.id = dids_user_phones.did_id
    and dids.phone_number = NEW.dst
    order by dids_user_phones.update_at desc
    limit 1;

    if @expired = 1 then
      set @queue_type = 1;
    else
      set @queue_type = 2;
    end if;

    select email into @email from users
    inner join user_phones up 
    on up.user_id = users.id
    and up.id = @user_phone_id;

    if @email is not NULL then
      insert into call_queue set email = @email,
      calling = NEW.dst,
      caller = @source,
      queue_type = @queue_type,
      call_time = NEW.billsec,
      start_date = @start_date,
      created_at = NOW(),
      time_left = @time_left;
    end if;
  end;
