class CallQueue < ActiveRecord::Base
  set_table_name 'call_queue'
  named_scope :unprocessed, {conditions:{processed: false}}
  
  def formatted_call_time
    format_seconds(self.call_time)
  end
  
  def formatted_time_left
    format_seconds(self.time_left)    
  end

  def self.format_seconds(seconds)
    total_minutes = seconds / 1.minute
    seconds_in_last_minute = seconds - total_minutes.minutes.seconds
    if total_minutes > 0
      label = total_minutes == 1 ? 'minute' : 'minutes'
      label_s = seconds_in_last_minute == 1 ? 'second' : 'seconds'
      if seconds_in_last_minute >0
        "#{total_minutes} #{label} and #{seconds_in_last_minute} #{label_s}"
      else
        "#{total_minutes} #{label}"
      end
    else
      label = seconds_in_last_minute == 1 ? 'second' : 'seconds'
      "#{seconds_in_last_minute} #{label}"
    end
  end

  def format_seconds(seconds)
    self.class.format_seconds(seconds)
  end
end