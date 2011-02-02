class CallQueue < ActiveRecord::Base
  set_table_name 'call_queue'
  named_scope :unprocessed, {conditions:{processed: false}}
end