require 'savon'

class Voipms
  attr_accessor :did, :username, :password, :cookie, :client, :login_params
  ACCOUNT = 115470

  def logger
    RAILS_DEFAULT_LOGGER
  end
  
  def initialize(opts={})
    @username = opts[:username]
    @password = opts[:password]
    login_info_from_file if opts[:username].blank?
    @cookie = opts[:cookie]
    @client = Savon::Client.new('https://voip.ms/api/v1/server.php')
    @login_params = {'api_username'=>@username, 'api_password'=>@password}
  end
    
  def process_keys(key,items=[])
    value = nil
    o = nil
    items.each do |i|
      if i[:key] == key
        o = OpenStruct.new(convert_stupid_to_hash(i[:value][:item]))
        break
      end
    end
    o
  end
  
  def convert_stupid_to_hash(stupid = [])
    stupid.inject({}) do |h,item|
      h[item[:key]] = item[:value]
      h
    end
  end  
    
  def process_balance_response(response)
    r = response.to_hash[:get_balance_response]
    items = r[:return][:item]
    o = process_keys('balance',items)
  rescue => e
    logger.error("process_balance_response: #{e.message}")
    raise "Response problem"
  end
  
  def balance
    response = @client.get_balance! do |soap| 
      soap.version = 2
      h =  {'params'=>[login_params.merge({'advanced'=>false})]}
      soap.body = h
    end
    process_balance_response(response)
  end
  
  def process_available_dids_response(response)
    r = response.to_hash[:get_dids_usa_response]
    items = r[:return][:item]
    dids = []
    items.each do |i| 
      if i[:key] == 'dids'
        dids = i[:value][:item]
        break
      end
    end
    logger.debug(dids.inspect)
    dids.map do |did|
      o = OpenStruct.new(convert_stupid_to_hash(did[:item]))
    end
  rescue => e
    logger.error("process_balance_response: #{e.message}")
    raise "Response problem"
  end
    
  def available_dids(rate_center='BALTIMORE',state='MD')
    response = @client.get_dids_usa! do |soap| 
      soap.version = 2
      soap.body = {'params'=>[login_params.merge({'state'=>state,'ratecenter'=>rate_center})]}
    end
    process_available_dids_response(response)
  end
  
  def process_order_did_response(response)
    r = response.to_hash[:order_did_response]
    r[:return][:item][:value] == 'success'
  end
  
  def order_did(did)
    response = @client.order_did! do |soap|
      soap.version = 2
      test = RAILS_ENV != 'production'
      h =  {'params'=>[login_params.merge({'did'=>did, 'pop'=>8, 'routing'=>"account:#{ACCOUNT}", 'cnam'=>0, 'billing_type'=>1, 'dialtime'=>60,'test'=>test})]}
      soap.body = h
    end
    process_order_did_response(response)
  end
  
  def order(ratecenter, state,did=nil)
    first_did = did.blank? ? available_dids(ratecenter,state).first : did
    raise "Unable to get DIDs" if first_did.blank?
    if order_did(first_did.did)
      did_number = first_did.did
      d = Did.new(phone_number: did_number,usage_state: Did::ACTIVE, state: state, city: ratecenter)
      d.save!
      d
    end
  rescue => e
    logger.error("order: #{e.message}")
  end  
  
  def login_info_from_file
    s = File.read("#{RAILS_ROOT}/config/current_provider_login")
    h = JSON::parse(s)
    @username = h['username']
    @password = h['password']
  end

end