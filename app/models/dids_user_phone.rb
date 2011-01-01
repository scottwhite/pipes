class DidsUserPhone < ActiveRecord::Base
  belongs_to :user_phone
  belongs_to :did
  after_destroy :set_did_to_active


  def set_did_to_active
    self.did.usage_state = Did::ACTIVE
    self.did.save!
  end
end