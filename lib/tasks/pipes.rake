namespace :numbers do
  desc "expires numbers over their alloated usage or time period"
  task :expire=>:environment do
    Did.update_expired
  end
end