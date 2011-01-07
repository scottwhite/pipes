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
    options.merge(user_phone: self)
    if options[:state].blank?
      phone_info = CloudVox.state_rate_center(self.number)
      options[:city] = phone_info[:ratecenter]
      options[:state] = phone_info[:state]
    end
    did = Did.order(options)
    did.usage_state = Did::IN_USE
    did.save!
    self.dids << did
    self.save!
    did
  end
  
  def convert_number
    self.number = self.class.convert_number(self.number)
  end
  
  def self.convert_number(number)
    number.gsub(/[\.,\-,\s,\(,\)]/,'')
  end
end