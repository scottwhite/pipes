class UserPhone < ActiveRecord::Base
  has_many :dids_user_phones
  has_many :dids, through: :dids_user_phones
  
end