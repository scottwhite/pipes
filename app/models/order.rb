class Order < ActiveRecord::Base
  attr_reader :raw_status
  belongs_to :user
  belongs_to :user_phone
  belongs_to :product
  
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
    return unless self.status == COMPLETED
    self.process_for_product
  rescue => e
    logger.error("process: #{gateway.inspect}")
    logger.error("process: #{e.message}")
    self.status = ERROR
    self.save
  end
  
  
  def process_for_product
    case self.product.id
      when Product::PIPES_NUMBER then
        self.user_phone.order_and_assign({state: self.state, city: self.city})  if (self.status == COMPLETED)
      when Product::PIPES_REUP then
        self.user_phone.reup 
      when Product::PIPES_EXTEND then
        logger.debug("process_for_product: #{self.inspect}")
        self.user_phone.extend_time
    end
  end
  
  
  def self.create_for(phone, product)
    self.create(user: phone.user, user_phone_id: phone.id, status: INITIAL, amount: product.price, product_id: product.id)
  end
  
  def self.pipes_number(phone)
    product = Product.pipes_number
    self.create_for(phone, product)
  end
  
  def self.reup_pipes(phone)
    product = Product.pipes_reup
    self.create_for(phone, product)
  end
  
  def self.extend_pipes(phone)
    product = Product.pipes_extend
    self.create_for(phone,product)
  end

  def self.verify(order_id)
    o = self.find(order_id)
    raise "Order already processed" unless o.status == INITIAL
    o
  end
    
end