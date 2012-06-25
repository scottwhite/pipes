class CallLog < ActiveRecord::Base
  named_scope :by_pipes_number, lambda{|number|
    # unless number =~ /^\+1/
    #   number = "+1#{number}"
    # end
    return {} if number.blank?
    {conditions: {pipes_number: number}}
  }
end
