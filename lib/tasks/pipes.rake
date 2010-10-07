namespace :numbers do
  desc "expires numbers over their alloated usage or time period"
  task :expire=>:environment do
    Did.in_use.map do |n|
      if n.dids_user_phone.present? 
        if (n.dids_user_phone.created_at >= 3.weeks.since) || (n.dids_user_phone.current_usage >= 1200)
          n.usage_state = Did.DISABLED
          n.save!
        end
      end
    end
  end
end