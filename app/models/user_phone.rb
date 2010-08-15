class UserPhone < ActiveRecord::Base
  has_many :dids_user_phones
  has_many :dids, through: :dids_user_phones
  
  has_many :active_dids, through: :dids_user_phones,conditions: ["dids.active = ?", true]
  
  def order_and_assign(options={})
    options.merge(user_phone: self)
    did = Did.order(options)
    did.usage_state = Did::IN_USE
    self.dids<< did
    self.save!
  end
end