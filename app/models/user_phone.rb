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

  def friendly_phone_number
    return if number.blank?
    m= number.match(/(\d{3})(\d{3})(\d{4})/)
    "#{m[1]} #{m[2]} #{m[3]}"
  end
  
end