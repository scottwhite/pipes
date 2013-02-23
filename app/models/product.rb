class Product < ActiveRecord::Base
  has_many :orders
  
  # Not sure might go to a code instead for system gigs
  
  PIPES_NUMBER = 1
  PIPES_EXTEND = 2
  PIPES_REUP = 3
  
  def self.pipes_number
    self.find(PIPES_NUMBER)
  end
  
  def self.pipes_extend
    self.find(PIPES_EXTEND)
  end
  
  def self.pipes_reup
    self.find(PIPES_REUP)
  end

  def self.requiring_number
    self.find(:all, :conditions => ['requires_existing = 1 AND active = 1'])
  end

  def self.not_requiring_number
    self.find(:all, :conditions => ['requires_existing = 0 AND active = 1'])
  end

end