class CallLog < ActiveRecord::Base

  def self.by_pipes_number(dup)
    did = dup.did
    number = did.phone_number
    number = "+1#{number}" unless number =~ /^\+1/
    tw = TwilioProvider.new
    
    called_from = tw.account.calls.list(from: number,start_date: dup.created_at, end_date:dup.expiration_date, page_size:100)
    called_to = tw.account.calls.list(to: number,start_date: dup.created_at, end_date:dup.expiration_date, page_size:100)

    data = {calls:[], total:0}
    return data if called_from.blank? && called_to.blank?
    called_from.each do |cf|
      data[:calls] <<  load_it_up(cf)
    end
    called_to.each do |cf|
      data[:calls]<< load_it_up(cf)
    end
    data[:calls].sort!
    data[:total] = called_from.total  + called_to.total
    data
  end
  
  private
  def self.load_it_up(tw_call)
    meths = [:to, :from, :date_created, :date_updated, :status, :start_time, :end_time, :duration, :direction]
    h = meths.inject({}) do |h,m| 
        v = tw_call.__send__(m)
        if(m=~/date_|_time/ && !v.blank?)
          h["#{m}_rfc822"] =  v
          v = Time.parse(v)

        end
        h[m] = v
        h
      end
    class << h
      def <=>   (other)
          other[:date_updated] <=> self[:date_updated] 
      end
    end
    h
  end

end
