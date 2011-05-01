class TwilioProvider
  SID = 'AC584a27ef4e2a013398ad27b5bcdb16a3'
  AUTH_TOKEN = '5602b73423d50848001fb55d719c6c8a'
  
  PIPES_PROCESS_URL = 'http://process.pipes.io/incoming'
  
  
  attr_accessor :did_id, :did, :sid
  
  def logger
    RAILS_DEFAULT_LOGGER
  end  
  
  def initialize
    self.class.connect
  end
  
  def did
    @did || Did.find(:first, conditions:{provider: 'twilio', provider_id: @sid}) if @sid
  end
  
  def order_did(did)
    # {"TwilioResponse"=>{"IncomingPhoneNumber"=>{"Sid"=>"PN7acbb73ec9e30540474c762a5e2857f7", "AccountSid"=>"AC584a27ef4e2a013398ad27b5bcdb16a3", "FriendlyName"=>"(410) 514-6084", "PhoneNumber"=>"+14105146084", "VoiceUrl"=>nil, "VoiceMethod"=>"POST", "VoiceFallbackUrl"=>nil, "VoiceFallbackMethod"=>"POST", "VoiceCallerIdLookup"=>"false", "DateCreated"=>"Thu, 07 Apr 2011 00:06:59 +0000", "DateUpdated"=>"Thu, 07 Apr 2011 00:06:59 +0000", "SmsUrl"=>nil, "SmsMethod"=>"POST", "SmsFallbackUrl"=>nil, "SmsFallbackMethod"=>"POST", "Capabilities"=>{"Voice"=>"true", "SMS"=>"true"}, "StatusCallback"=>nil, "StatusCallbackMethod"=>nil, "ApiVersion"=>"2010-04-01", "Uri"=>"/2010-04-01/Accounts/AC584a27ef4e2a013398ad27b5bcdb16a3/IncomingPhoneNumbers/PN7acbb73ec9e30540474c762a5e2857f7"}}}
    response = Twilio::IncomingPhoneNumber.create(:PhoneNumber=>did)
    r = parse_response(response.parsed_response)
    logger.info(response.parsed_response.inspect)
    r['IncomingPhoneNumber']
  end
  
  def parse_response(response)
    response['TwilioResponse']
  end
  
  def voice_url(id)
    id = id || self.did.id unless self.did.blank?
    "#{PIPES_PROCESS_URL}/#{id}"
  end

  def get_did(sid)
    response = Twilio::IncomingPhoneNumber.get(sid)
    r = parse_response(response.parsed_response)
    logger.info(r.inspect)
    r
  end
  
  def set_voice_url(sid, id=nil)
    @sid = sid
    self.update(sid, :VoiceUrl=>self.voice_url(id))
  end
  
  def update(sid,options={})
    response = Twilio::IncomingPhoneNumber.update(sid,options)
    r = parse_response(response.parsed_response)
    logger.info(r.inspect)
    r
  end
  
  def convert_number(number)
    number.gsub(/^\+1/,'')
  end
  
  def order(number,did=nil)
    count = (count)?count+1:0
    logger.debug("order: count is #{count}")
    first_did = did.blank? ? available_dids(number).first : did
    
    raise "Unable to get DIDs" if first_did.blank?
    raise "Unable to order" unless order = order_did(first_did['PhoneNumber'])
    
    did_number = convert_number(first_did['PhoneNumber'])
    d = Did.new(phone_number: did_number,usage_state: Did::ACTIVE, state: first_did['Region'], city: first_did['RateCenter'], provider: 'twilio', provider_id: order['Sid'])
    d.save!
    self.set_voice_url(order['Sid'],d.id)
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
    dids = Twilio::AvailablePhoneNumbers.search_local(near_number: number)
    # retarded xml, WHY? TODO: roll own, this is stupid
    x = parse_response(dids.parsed_response)["AvailablePhoneNumbers"]['AvailablePhoneNumber']
    logger.debug("available_dids: #{x.inspect}")
    x
  end
  
  
  def first_available_did(number)
    dids = available_dids(number)
    dids.first
  end
  
  def self.connect
    @connection ||= Twilio.connect(SID,AUTH_TOKEN)
  end
  
end

