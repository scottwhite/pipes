class DidsUserPhone < ActiveRecord::Base
  belongs_to :user_phone
  belongs_to :did
end