class Did < ActiveRecord::Base
  DISABLED = 0
  ACTIVE = 1
  IN_USE = 2
  WAITING = 3
  INTERNAL = 4


  has_one :dids_user_phone, :conditions=>["dids_user_phones.expire_state <> #{DidsUserPhone::DEAD}"]
  has_one :last_used, class_name: 'DidsLastUsed'

  named_scope :available_by_city, lambda{|state,city|
    {conditions: {usage_state: ACTIVE, state: state.downcase, city: city.downcase}}
    }
  
  named_scope :available_by_state, lambda{|state|
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
    did = Did.active.first if did.blank?
    if did.blank?
      cp = current_provider.new
      did = cp.order(options[:city],options[:state])
      did = cp.order(nil,options[:state]) if did.blank?
    end
   did
  end
  
  
  def friendly_phone_number
    return if phone_number.blank?
    m= phone_number.match(/(\d{3})(\d{3})(\d{4})/)
    "#{m[1]} #{m[2]} #{m[3]}"
  end
  
  def time_left
    return if self.dids_user_phone.blank?
    CallQueue.format_seconds(self.dids_user_phone.time_left)
  end
  
  def expires_at
    return if self.dids_user_phone.blank?
    self.dids_user_phone.expiration_date
  end
  
  
  def expired?
    dup = self.dids_user_phone
    return true if dup.blank?
    dup.expire_state > 0 || dup.current_usage >= dup.time_allotted || dup.expiration_date >= Time.now()
  end
  
  def can_reup?
    dup = self.dids_user_phone
    return false if dup.blank?
    !dup.dead?
  end
  
  def self.update_expired
    self.connection.execute(%Q{update dids
      inner join dids_user_phones dup
      on dup.did_id = dids.id
      and dids.usage_state = #{IN_USE}
      set usage_state = 0,
      dup.expired=1,
      dids.updated_at = NOW(),
      dup.updated_at = NOW()
      where dup.current_usage >= dup.time_allotted or dup.created_at <= date_sub(NOW(), INTERVAL 3 WEEK)})
  end
  
  def self.update_to_active
    self.connection.execute(%Q{update dids
      set usage_state = #{ACTIVE},
      updated_at = NOW()
      where usage_state = #{DISABLED} 
      and updated_at <= date_sub(NOW(), INTERVAL 1 WEEK)})
  end
  
end