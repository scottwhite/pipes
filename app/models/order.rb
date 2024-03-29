require 'digest/sha1'
require 'securerandom'

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
    case status.downcase
    when 'completed' then
      COMPLETED
    when 'failed' then
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
    false
  end
  
  def process_in_app
    self.status = COMPLETED
    self.save!
    return unless self.status == COMPLETED
    self.process_for_product
  rescue => e
    logger.error("process: #{e.message}")
    self.status = ERROR
    self.save
    false
  end
  
  def process_for_product
    case self.product.product_type
      when Product::PIPES_NUMBER then
        self.user_phone.order_and_assign({state: self.state, city: self.city})  if (self.status == COMPLETED)
      when Product::PIPES_REUP then
        # todo logic to check for did in order if no did user current one from user
        dids = self.user.current_dids
        return false if dids.blank?
        dids.first.reup
      when Product::PIPES_EXTEND then
        logger.debug("process_for_product: #{self.inspect}")
        # todo logic to check for did in order if no did user current one from user
        dids = self.user.current_dids
        return false if dids.blank?
        dids.first.extend_time
    end
  end

  def generate_gateway_token
    token = SecureRandom.urlsafe_base64(18)
    self.gateway_trans_id = token
    token
  end  

  def processed?
    (self.status == COMPLETED || self.status == ERROR)
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
  
  def self.nuke_unused(time=48.hours.ago)
    delete_all(["status = #{INITIAL} and created_at > ?",48.hours.ago])
  end
    
end