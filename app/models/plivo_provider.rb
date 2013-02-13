class PlivoProvider
  AUTH_ID = 'MAODDKMTU3MZVLNTA0MJ'
  AUTH_TOKEN = 'YjljNjY5OTllOTBhZDBmMjk1MTYwYWFmYmJmZDU2'
  # APP_SID = 'APaebf287000ce4318bee561df1b85f693'
  # include Plivo
  
  attr_accessor :did_id, :did, :sid, :account, :connection
  
  def logger
    RAILS_DEFAULT_LOGGER
  end  
  
  def initialize
    @connection = Plivo::RestAPI.new(AUTH_ID,AUTH_TOKEN)
    # @account = @connection.account
  end

  def applications
    response = @connection.get_applications
    response.last['objects'].map do |o|
      OpenStruct.new(o)
    end
  end

  def existing_numbers
    response = @connection.get_numbers
    response.last['objects'].map do |o|
      rn = RentedNumber.new(o)
      rn.connection = @connection
      rn
    end
  end

  def generate_capability_token(user)
  end
  
  def did
    @did || Did.find(:first, conditions:{provider: 'plivo', provider_id: @sid}) if @sid
  end
    
  def voice_url(id)
    id = id || self.did.id unless self.did.blank?
    "#{PIPES_PROCESS_URL}/incoming/#{id}"
  end

  def callback_url(id)
    id = id || self.did.id unless self.did.blank?
    "#{PIPES_PROCESS_URL}/status/#{id}"
  end

  def get_did(sid)
    @account.incoming_phone_numbers.get(sid)
    response = @connection.get_number({'number': sid})
    rn = RentedNumber.new(response.last['objects'].first)
    rn.connection = @connection
  end
  
  def set_voice_url(sid, id=nil)
    @sid = sid
    # self.update(sid, :voice_url=>self.voice_url(id),:status_callback=> self.callback_url(id))
  end
  
  def update(sid,options={})
    # response = @account.incoming_phone_numbers.get(sid).update(options)
    response
  end
  
  def convert_number(number)
    number.gsub(/^\+?1/,'')
  end
  
  def order(number)
    count = (count)?count+1:0
    logger.debug("order: count is #{count}")
    rented_number = rent_number(number)
    raise "Unable to order" unless rented_number
    
    did_number = convert_number(rented_number)
    d = Did.new(phone_number: did_number,usage_state: Did::ACTIVE, state: first_did.region, provider: 'plivo', provider_id: rented_number)
    d.save!
    # self.set_voice_url(order.sid,d.id)
    d
  rescue => e
    logger.error("order: #{e.message}")
    if count < 2
      ratecenter = nil
      logger.info("order: retrying")
      retry 
    end
  end  
    
  # [200, 
  # {"meta"=>{"previous"=>nil, "total_count"=>4, "offset"=>0, "limit"=>20, "next"=>nil}, 
  # "api_id"=>"0ff93712-7482-11e2-8ec2-22000abc9514", 
  # "objects"=>[
  #     {"stock"=>40, "voice_enabled"=>true, "region"=>"Maryland, UNITED STATES", "voice_rate"=>"0.00900", "prefix"=>"443", "sms_rate"=>"0.00800", "number_type"=>"local", "setup_rate"=>"0.00000", "rental_rate"=>"0.80000", "group_id"=>"11304129421048", "sms_enabled"=>true, "resource_uri"=>"/v1/Account/MAODDKMTU3MZVLNTA0MJ/AvailableNumberGroup/11304129421048/"}, 
  #     {"stock"=>39, "voice_enabled"=>true, "region"=>"Maryland, UNITED STATES", "voice_rate"=>"0.00900", "prefix"=>"240", "sms_rate"=>"0.00800", "number_type"=>"local", "setup_rate"=>"0.00000", "rental_rate"=>"0.80000", "group_id"=>"11169107518841", "sms_enabled"=>true, "resource_uri"=>"/v1/Account/MAODDKMTU3MZVLNTA0MJ/AvailableNumberGroup/11169107518841/"}, {"stock"=>21, "voice_enabled"=>true, "region"=>"Maryland, UNITED STATES", "voice_rate"=>"0.00900", "prefix"=>"301", "sms_rate"=>"0.00800", "number_type"=>"local", "setup_rate"=>"0.00000", "rental_rate"=>"0.80000", "group_id"=>"11194626513846", "sms_enabled"=>true, "resource_uri"=>"/v1/Account/MAODDKMTU3MZVLNTA0MJ/AvailableNumberGroup/11194626513846/"}, {"stock"=>3, "voice_enabled"=>true, "region"=>"Maryland, UNITED STATES", "voice_rate"=>"0.00900", "prefix"=>"410", "sms_rate"=>"0.00800", "number_type"=>"local", "setup_rate"=>"0.00000", "rental_rate"=>"0.80000", "group_id"=>"11264788201583", "sms_enabled"=>true, "resource_uri"=>"/v1/Account/MAODDKMTU3MZVLNTA0MJ/AvailableNumberGroup/11264788201583/"}
  #   ]
  # }]  

  def rent_number(number)
    params = {country_iso: 'US', prefix: number.to_s.slice(0,3)}
    groups = @connection.get_number_group(params)
    unless (groups.last['meta'].total_count > 0)
      params.delete(prefix)
      groups = @connection.get_number_group(params)
    end
    group = OpenStruct(groups.last['objects'].first)
    response = rent_from_number_group({'group_id'=> group.group_id, 'quantity'=>1})
    raise "No numbers" unless response.last['status'] == 'fulfilled'
    number =number_from_response(response)
    OpenStruct.new({'region'=> group.region.sub(/\,\s.+/,''), number: number})
  end

  # [201, {"status"=>"fulfilled", "message"=>"created", "numbers"=>[{"status"=>"Success", "number"=>"13013927377"}], "api_id"=>"004a8c7c-748b-11e2-9b52-1231410119dd"}]
  def number_from_response(response)
    numbers = response.last['numbers']
    numbers.first['number']
  end
  
  def self.connect
    @connection ||= Plivo::RestAPI.new(AUTH_ID,AUTH_TOKEN)
  end


  class RentedNumber
    attr_accessor :voice_enabled, :sms_enabled, :fax_enabled, :number, :application, :connection
    attr_reader :voice_rate, :monthly_rental_rate, :carrier, :sms_rate, :number_type, :sub_account, :added_on, :resource_uri

    def initialize(attrs={})
      attrs.each do |k,v|
        sym = "@#{k}"
        self.instance_variable_set(sym.to_sym,v)
      end
    end

    def update_application(app_id)
      # https://www.plivo.com/docs/api/numbers/number/#number_edit
      @connection.link_application_number({'number'=> self.number, 'app_id'=> app_id})
    end

    def save
      update_application(self.application)
    end

    def release
      @connection.unrent_number({'number'=> self.number})
    end
  end
  

end

