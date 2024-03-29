class Did < ActiveRecord::Base
  DISABLED = 0
  ACTIVE = 1
  IN_USE = 2
  WAITING = 3
  INTERNAL = 4


  has_one :dids_user_phone, dependent: :destroy, :conditions=>["dids_user_phones.expire_state <> #{DidsUserPhone::DEAD}"]
  has_one :last_used, class_name: 'DidsLastUsed'

  named_scope :available_by_city, lambda{|state,city|
    return {} if(state.blank? && city.blank?)
    {conditions: {usage_state: ACTIVE, state: state.downcase, city: city.downcase}}
    }
  
  named_scope :available_by_state, lambda{|state|
    {conditions: {usage_state: ACTIVE, state: state.downcase}}
    }
  
  named_scope :active, {conditions: {usage_state: ACTIVE}}
  named_scope :in_use, {conditions: {usage_state: IN_USE}}
  named_scope :internal, {conditions: {usage_state: INTERNAL}}
  def self.current_provider
    # @current_provider ||= Voipms
    @current_provider ||= TwilioProvider
  end
  
  def self.order(options={})
    cp = current_provider.new
    cp.order(options[:user_phone].number)
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
    dup.expire_state > 0 || dup.current_usage >= dup.time_allotted || dup.expiration_date <= Time.now()
  end
  
  def can_reup?
    dup = self.dids_user_phone
    return false if dup.blank?
    dup.expiration_date + 1.week > Time.now
  end

  def reup
    if self.expired?
      return false unless self.can_reup?
    end
    self.update_attributes(usage_state: Did::IN_USE)
    dup = self.dids_user_phone
    raise "No mapping to re-up" if dup.blank?
    dup.update_attributes(expire_state: DidsUserPhone::OPEN, expiration_date: dup.expiration_date + 3.weeks, time_allotted: dup.time_allotted + 1200)
    self
  end
  
  def extend_time(time=1800)
    return false if self.expired?
    logger.debug("extend_time: entry")
    dup = self.dids_user_phone
    raise "No mapping to extend" if dup.blank?
    logger.debug("extend_time: #{time}")
    dup.update_attributes(time_allotted: dup.time_allotted + time)
    self
  end
  
  
  def self.update_expired
    one_week = 1.week.from_now.to_s(:db)
    self.connection.execute(%Q{update dids
      inner join dids_user_phones dup
      on dup.did_id = dids.id
      and dids.usage_state = #{IN_USE}
      set usage_state = 0,
      dup.expire_state = 1,
      dids.updated_at = NOW(),
      dup.updated_at = NOW()
      where dup.expire_state = 0 and (dup.current_usage >= dup.time_allotted or dup.expiration_date < '#{one_week}')})
  end

  def self.release_expired
    dids = Did.all(conditions:{usage_state: 0})
    return if dids.blank?
    check_it = dids.inject({})do |h,v|
      h[v.phone_number] = v.id
      h
    end
    provider = self.current_provider.new
    number_list = provider.account.incoming_phone_numbers.list
    number_list.each do |number| 
      n = number.phone_number.gsub(/\+1/,'')
      logger.debug(n)
      if check_it[n]
        number.delete
        Did.destroy(check_it[n])
      end
    end
  rescue => e 
    logger.error("unable to release: #{n}")
    logger.error(e.message)
  end
  
  def self.update_to_active
    self.connection.execute(%Q{update dids
      set usage_state = #{ACTIVE},
      updated_at = NOW()
      where usage_state = #{DISABLED} 
      and updated_at <= date_sub(NOW(), INTERVAL 1 WEEK)})
  end

  def self.clear_expired_numbers
    self.connection.execute(%Q{update dids
      delete from dids_user_phones dup
      on dup.did_id = dids.id
      and dids.usage_state = #{IN_USE}
      set usage_state = 0,
      dup.expire_state = 1,
      dids.updated_at = NOW(),
      dup.updated_at = NOW()
      where dup.expire_state = 0 and (dup.current_usage >= dup.time_allotted or dup.expiration_date < NOW())})
  end
  
end