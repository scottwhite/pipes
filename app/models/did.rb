class Did < ActiveRecord::Base
  DISABLED = 0
  ACTIVE =1
  IN_USE = 2


  has_one :dids_user_phone
  
  named_scope :available_by_region, lambda{|city,state|
    {conditions: {usage_state: ACTIVE, state: state.downcase, city: city.downcase}}
    }
  
  def self.current_provider
    @current_provider ||= Voipms
  end
  
  def self.order(options={})
    raise "Need city and state" if options[:city].blank? || options[:state].blank?
    did = Did.available_by_region(options[:city],options[:state]).first
    if did.blank?
      cp = current_provider.new
      cp.login
      did = cp.order(options[:city],options[:state])
    end
   did
  end
  
  def friendly_phone_number
    return if phone_number.blank?
    m= phone_number.match(/(\d{3})(\d{3})(\d{4})/)
    "#{m[1]} #{m[2]} #{m[3]}"
  end
  
end