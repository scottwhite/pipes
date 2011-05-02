class UserPhone < ActiveRecord::Base
  GOOD_NUMBER = /^\D?(\d{3})\D?\D?(\d{3})\D?(\d{4})$/
  has_many :dids_user_phones, dependent: :destroy
  has_many :dids, through: :dids_user_phones
  
  has_many :active_dids, through: :dids_user_phones,conditions: ["dids.active = ?", true]
  belongs_to :user
  
  validates_presence_of     :number
  validates_length_of       :number,    :within => 10..100 #r@a.wk
  
  validates_format_of       :number, with: GOOD_NUMBER
  
  
  before_save :convert_number
    
  def order_and_assign(options={})
    options.merge!(user_phone: self)
    if options[:state].blank?
      phone_info = CloudVox.state_rate_center(self.number)
      options[:city] = phone_info[:ratecenter]
      options[:state] = phone_info[:state]
    end
    did = Did.order(options)
    
    did.usage_state = Did::IN_USE
    did.save!
    if lu = did.last_used
      # nuke if someone gets the same number by chance 2 cycles in a row
      lu.delete if lu.number = self.number
    end
    self.dids << did
    self.save!
    dup = DidsUserPhone.find(:first, conditions: {expire_state: 0, did_id: did.id, user_phone_id: self.id})
    dup.update_attributes(expiration_date: Time.now + 3.weeks)
    did
  end
  
  
  def reup(requested_did=nil)
    did = requested_did || current_did
    did.update_attributes(usage_state: Did::IN_USE)
    dup = did.dids_user_phone
    raise "No mapping to re-up" if dup.blank?
    dup.update_attributes(expire_state: DidsUserPhone::OPEN, expiration_date: dup.expiration_date + 3.weeks, time_allotted: dup.time_allotted + 1200)
    did
  end
  
  
  def extend_time(time=1800,requested_did=nil)
    logger.debug("extend_time: entry")
    did = requested_did || current_did
    dup = did.dids_user_phone
    raise "No mapping to extend" if dup.blank?
    logger.debug("extend_time: #{time}")
    dup.update_attributes(time_allotted: dup.time_allotted + time)
    did
  end
  
  def current_did
    dup = self.dids_user_phones.select do |dup|
      !dup.dead?
    end.first
    dup.did
  end
  
  def convert_number
    self.number = self.class.convert_number(self.number)
  end
  
  def self.convert_number(number)
    number.gsub(/[\.,\-,\s,\(,\)]/,'')
  end
end