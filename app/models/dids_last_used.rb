class DidsLastUsed < ActiveRecord::Base
  set_table_name 'dids_last_used'
  set_primary_key 'did_id'
  belongs_to :did
  
end