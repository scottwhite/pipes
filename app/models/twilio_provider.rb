class TwilioProvider
  SID = 'AC584a27ef4e2a013398ad27b5bcdb16a3'
  AUTH_TOKEN = '5602b73423d50848001fb55d719c6c8a'
  APP_SID = 'APaebf287000ce4318bee561df1b85f693'
  PIPES_PROCESS_URL = 'http://process.pipes.io/incoming'
  
  
  attr_accessor :did_id, :did, :sid, :account
  
  def logger
    RAILS_DEFAULT_LOGGER
  end  
  
  def initialize
    @connection = Twilio::REST::Client.new(SID,AUTH_TOKEN)
    @account = @connection.account
  end


  def generate_capability_token(username,phone)
    capability = Twilio::Util::Capability.new SID, AUTH_TOKEN
    capability.allow_client_outgoing  APP_SID
    capability.allow_client_incoming phone
    capability.generate
  end
  
  def did
    @did || Did.find(:first, conditions:{provider: 'twilio', provider_id: @sid}) if @sid
  end
  
  def order_did(did)
    response = @account.incoming_phone_numbers.create(:phone_number => did)
    response
  end
  
  def parse_response(response)
    response['TwilioResponse']
  end
  
  def voice_url(id)
    id = id || self.did.id unless self.did.blank?
    "#{PIPES_PROCESS_URL}/#{id}"
  end

  def get_did(sid)
    @account.incoming_phone_numbers.get(sid)
  end
  
  def set_voice_url(sid, id=nil)
    @sid = sid
    self.update(sid, :voice_url=>self.voice_url(id))
  end
  
  def update(sid,options={})
    response = @account.incoming_phone_numbers.get(sid).update(options)
    response
  end
  
  def convert_number(number)
    number.gsub(/^\+1/,'')
  end
  
  def order(number)
    count = (count)?count+1:0
    logger.debug("order: count is #{count}")
    first_did = available_dids(number).first
    
    raise "Unable to get DIDs" if first_did.blank?
    raise "Unable to order" unless order = order_did(first_did.phone_number)
    
    did_number = convert_number(first_did.phone_number)
    d = Did.new(phone_number: did_number,usage_state: Did::ACTIVE, state: first_did.region, city: first_did.rate_center, provider: 'twilio', provider_id: order.sid)
    d.save!
    self.set_voice_url(order.sid,d.id)
    d
  rescue => e
    logger.error("order: #{e.message}")
    if count < 2
      ratecenter = nil
      logger.info("order: retrying")
      retry 
    end
  end  
    
  def available_dids(number)
    @account.available_phone_numbers.get('US').local.list(near_number: number)
  end
  
  
  def first_available_did(number)
    dids = available_dids(number)
    dids.first
  end
  
  def self.connect
    @connection ||= Twilio::REST::Client.new(SID,AUTH_TOKEN)
  end
  
end

