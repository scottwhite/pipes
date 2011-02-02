class Did < ActiveRecord::Base
  DISABLED = 0
  ACTIVE = 1
  IN_USE = 2
  INTERNAL = 3


  has_one :dids_user_phone

  named_scope :available_by_city, lambda{|state,city|
    {conditions: {usage_state: ACTIVE, state: state.downcase, city: city.downcase}}
    }
  
  named_scope :available_by_region, lambda{|state|
    {conditions: {usage_state: ACTIVE, state: state.downcase}}
    }
  
  named_scope :active, {conditions: {usage_state: ACTIVE}}
  named_scope :in_use, {conditions: {usage_state: IN_USE}}
  named_scope :internal, {conditions: {usage_state: INTERNAL}}
  def self.current_provider
    @current_provider ||= Voipms
  end
  
  def self.order(options={})
    raise "Need state" if options[:state].blank?
    did = Did.available_by_city(options[:state],options[:city]).first
    if did.blank?      
      cp = current_provider.new
      did = cp.order(options[:city],options[:state])
      did = Did.available_by_state(options[:state]).first if did.blank?
      did = cp.order(nil,options[:state]) if did.blank?
    end
   did
  end
  
  
  def friendly_phone_number
    return if phone_number.blank?
    m= phone_number.match(/(\d{3})(\d{3})(\d{4})/)
    "#{m[1]} #{m[2]} #{m[3]}"
  end
  
end