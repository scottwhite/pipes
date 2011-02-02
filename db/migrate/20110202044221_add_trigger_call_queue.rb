class AddTriggerCallQueue < ActiveRecord::Migration
  def self.up
    self.execute(%Q{
      create trigger insert_call_queue after insert on cdr
        for each row begin
          select (1200 - current_usage) as time_left, dids_user_phones.user_phone_id, dids_user_phones.created_at
          into @time_left, @user_phone_id, @start_date
          from dids_user_phones
          inner join dids on
          dids.id = dids_user_phones.did_id
          and dids.phone_number = NEW.dst;

          select email into @email from users
          inner join user_phones up 
          on up.user_id = users.id
          and up.id = @user_phone_id;


          insert into call_queue set email = @email,
          calling = NEW.dst,
          caller = NEW.userfield,
          call_time = NEW.billsec,
          start_date = @start_date,
          time_left = @time_left;
        end;
    })
  end

  def self.down
    self.execute(%Q{DROP TRIGGER IF EXISTS insert_call_queue})
  end
end
