class Order < ActiveRecord::Base
  attr_reader :raw_status
  belongs_to :user
  belongs_to :user_phone
  
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
    self.user_phone.order_and_assign({state: self.state, city: self.city})  if (self.status == COMPLETED)
  rescue => e
    logger.error("process: #{gateway.inspect}")
    logger.error("process: #{e.message}")
    self.status = ERROR
    self.save
  end
  
  def self.create_for(phone, user_order={})
    self.create(user: phone.user, user_phone_id: phone.id, state: user_order[:state], city: user_order[:city], status: INITIAL, amount: 3.00)
  end

  def self.verify(order_id)
    o = self.find(order_id)
    raise "Order already processed" unless o.status == INITIAL
    o
  end
    
end