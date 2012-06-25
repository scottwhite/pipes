class CallLog < ActiveRecord::Base

  def self.by_pipes_number(dup)
    did = dup.did
    number = did.phone_number
    number = "+1#{number}" unless number =~ /^\+1/
    tw = TwilioProvider.new
    meths = [:to, :from, :date_created, :date_updated, :status, :start_time, :end_time, :duration, :direction]
    called_from = tw.account.calls.list(from: number,start_date: dup.created_at, end_date:dup.expiration_date, page_size:100)
    called_to = tw.account.calls.list(to: number,start_date: dup.created_at, end_date:dup.expiration_date, page_size:100)

    data = {to:[], from:[]}
    called_from.each do |cf|
      data[:from] << meths.inject({}){|h,m| h[m] = cf.__send__(m);h}
    end
    called_to.each do |cf|
      data[:to]<< meths.inject({}){|h,m| h[m] = cf.__send__(m);h}
    end
    data[:total] = called_from.total  + called_to.total
    data
  end
  
end
