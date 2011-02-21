class DidsUserPhone < ActiveRecord::Base
  belongs_to :user_phone
  belongs_to :did
  after_destroy :set_did_to_active
  
  OPEN = 0
  EXPIRED = 1
  DEAD = 2

  def expired?
    self.expired_date <= Time.now || self.expire_state == EXPIRED
  end
  
  def dead?
    self.expire_state == DEAD
  end

  def set_did_to_active
    self.did.usage_state = Did::ACTIVE
    self.did.save!
  end
    
end