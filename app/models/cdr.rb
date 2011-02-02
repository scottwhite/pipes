class Cdr < ActiveRecord::Base
  set_table_name 'cdr'
  
  
  def call_time
   if src.billsec > 59
     
  end
end