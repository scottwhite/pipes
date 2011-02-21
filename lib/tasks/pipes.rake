namespace :numbers do
  desc "expires numbers over their alloated usage or time period"
  task :expire=>:environment do
    Did.update_expired
  end
  
  
  desc "update inactive numbers to active after 1 week wait"
  task :activate_waiting=>:environment do
    Did.update_to_active
  end
  
  desc "send out emails for who called"
  task :call_notification=>:environment do
    CallQueue.unprocessed.each do |cq|
      cq.update_attributes(processed: true)
      if q.queue_type == 1
        Mailer.deliver_recent_call_with_stats(cq)
      else
        Mailer.deliver_expired_notice(cq)
      end
    end
  end
end