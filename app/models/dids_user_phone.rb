class DidsUserPhone < ActiveRecord::Base
  belongs_to :user_phone
  belongs_to :did  
  
  named_scope :by_did_number, lambda{|number| {joins: [:did], conditions: ["dids.phone_number = ?", number]}}
  
  OPEN = 0
  EXPIRED = 1
  DEAD = 2



  def time_left
    self.time_allotted - self.current_usage
  end
  
  def expired?
    self.expiration_date <= Time.now || self.expire_state == EXPIRED
  end
  
  def dead?
    self.expire_state == DEAD
  end

  def set_did_to_active
    self.did.usage_state = Did::ACTIVE
    self.did.save!
  end

end