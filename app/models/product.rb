class Product < ActiveRecord::Base
  has_many :orders
  
  # Not sure might go to a code instead for system gigs
  
  PIPES_NUMBER = "PIPES_NUMBER"
  PIPES_EXTEND = "PIPES_EXTEND"
  PIPES_REUP = "REUP_20MINS"
  
  def self.pipes_number
    self.find(conditions: {product_type: PIPES_NUMBER})
  end
  
  def self.pipes_extend
    self.find(conditions: {product_type: PIPES_EXTEND})
  end
  
  def self.pipes_reup
    self.find(conditions: {product_type: PIPES_REUP})
  end

  def self.requiring_number(source_type)
    self.find(:all, :conditions => ['requires_existing = 1 AND active = 1 AND source = ?', source_type])
  end

  def self.not_requiring_number(source_type)
    self.find(:all, :conditions => ['requires_existing = 0 AND active = 1 AND source = ?', source_type])
  end

  def can_order?(did)
    if(self.product_type== PIPES_NUMBER)
      return true
    end
    if([PIPES_EXTEND, PIPES_REUP].include?(self.product_type) && !did)
      return false
    end

    if(self.product_type == PIPES_REUP)
      if did.expired?
        return false unless did.can_reup?
      end
    end
    if(self.product_type == PIPES_EXTEND)
      return false if did.expired?
    end
    true
  end

end