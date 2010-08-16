class UserPhone < ActiveRecord::Base
  has_many :dids_user_phones
  has_many :dids, through: :dids_user_phones
  
  has_many :active_dids, through: :dids_user_phones,conditions: ["dids.active = ?", true]
  
  before_save :convert_number
  
  def order_and_assign(options={})
    options.merge(user_phone: self)
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