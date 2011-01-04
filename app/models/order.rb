class Order < ActiveRecord::Base
  attr_reader :raw_status
  belongs_to :user
  INITIAL = 0
  FAILED = 1
  COMPLETED = 2
  UNKNOWN = 3
  ERROR = 4
  
  def raw_status=(status)
    @raw_status = status
    @status = translate_status(status)
  end
  
  def translate_status(status)
    case status
    when 'Completed' then
      COMPLETED
    when 'Failed' then
      FAILED
    else
      UNKNOWN
    end
  end
  
  def process(gateway={})
    self.status = self.translate_status(gateway[:raw_status])
    self.gateway_trans_id = gateway[:gateway_trans_id]
    self.save!
    self.user.request_number(state: self.state, city: self.city) if (self.status == COMPLETED)
  rescue => e
    logger.error("process: #{gateway.inspect}")
    logger.error("process: #{e.message}")
    logger.error("process: #{e.backtrace}")
    self.status = ERROR
    self.save
  end
  
  def self.create_for(user, user_order)
    self.create(user: user, state: user_order[:state], city: user_order[:city], status: INITIAL, amount: 3.00)
  end

  def self.verify(order_id)
    o = self.find(order_id)
    raise "Order already processed" unless o.status == INITIAL
    o
  end
    
end