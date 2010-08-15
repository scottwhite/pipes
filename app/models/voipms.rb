require 'json'

class Voipms
  attr_accessor :did, :username, :password, :cookie
  SERVER={:host=>'voip.ms',:port=>443,:timeout=>20,:number_retries=>1}
  ACCOUNT = 115470
  COOKIE_PATH = "#{RAILS_ROOT}/tmp/did_cookie"
  def logger
    RAILS_DEFAULT_LOGGER
  end
  
  def initialize(opts={})
    @username = opts[:username]
    @password = opts[:password]
    login_info_from_file if opts[:username].blank?
    @cookie = opts[:cookie]
  end
  
  def login_info_from_file
    s = File.read("#{RAILS_ROOT}/config/current_provider_login")
    h = JSON::parse(s)
    @username = h['username']
    @password = h['password']
  end
  
  def login(force=false)
    if File.exists?(COOKIE_PATH) && force==false
      stored_cookie
      return
    end
    form_data = {
      col_email: @username,
      col_password: @password,
      action:'login',
      button: 'Login'
    }
    @cookie= NetUtil::Request.hack_session_cookie('/m/login.php',form_data,SERVER)
    File.open(COOKIE_PATH,'w+'){|f| f.write(@cookie)}
    @cookie
  end
  
  def logout
    NetUtil::Request.send('/m/logout.php',nil,SERVER,{'Cookie'=>@cookie},true)
  end
  
  def stored_cookie
    @cookie = File.read(COOKIE_PATH)
    @cookie
  end
  
  def available_dids(city,state)
    count = (count)?+1:0
    query = {action: 'orderrc',
      state: state.upcase,
      rc: city.upcase
    }
    raise "I have no damn cookie" unless stored_cookie
    response, body = NetUtil::Request.send('/m/orderdid.php',query,SERVER,{'Cookie'=>@cookie})
    doc = Nokogiri::HTML.parse(body)
    first_did = doc.search("//input[@name='did[]']").first.attributes['value'].value
    RAILS_DEFAULT_LOGGER.debug("available_dids: first #{first_did}")
    # we aren't doing this right now.... so let's not bloat stuff
    # dids = doc.search("//input[@name='did[]']").map do |node|
    #   node.attribute('value').value
    # end
    [first_did]
  rescue NetUtil::InvalidResponseError => e
    if count < 1
      login(true)
      retry
    end
    raise e
  end
  
  # did comes from form like this
  # 4434513858:BALTIMORE:MD:0.99:0.01:0.50:4.95:1.00
  # <input name="ratecenter" type="hidden" id="ratecenter" value="BALTIMORE">
  #                   <input name="state" type="hidden" id="state" value="MD">
  #                   <input name="action" type="hidden" id="action3" value="orderdid">
  #                   </span>

  def pre_order(ratecenter,state,did)
    count = (count)?+1:0
    form_data = {
      'did[]'=>did,
      billingtype: 1,
      cnam: 0,
      pop: 8,
      routing1: 'account',   #okay
      account1: ACCOUNT,      #probably need to get this
      sys1: 'hangup',        
      account2: ACCOUNT,
      sys2: 'hangup',
      routing2: 'none',
      account3: ACCOUNT,
      sys3: 'hangup',
      routing3: 'none',
      account4: ACCOUNT,
      sys4: 'hangup',
      routing4: 'none',
      ratecenter: ratecenter,
      state: state,
      action: 'orderdid'
    }
    body = NetUtil::Request.post('/m/orderdidconfirm.php',form_data,SERVER,{'Cookie'=>@cookie})
    doc = Nokogiri::HTML.parse(body)
    # really brittle
    doc.search("//input[@id='submit']").first.attribute('value').value == 'Confirm order'
  rescue NetUtil::InvalidResponseError => e
    if count < 1
      login(true)
      retry
    end
    raise e
  end

  def confirm_order(ratecenter,state,did)
    count = (count)?+1:0
    form_data = {
      'did[]' => did,
      pop: 8,
      cnam: 0,
      billingtype: 1,
      action: 'order',
      routing1: "account:#{ACCOUNT}",
      routing2: 'none:',
      routing3: 'none:',
      routing4: 'none:',
    }
    # throws down a 302 on success, how awesome is that cause a bad cookie is a 302, sigh need to get headers
    body = NetUtil::Request.post('/m/orderdidconfirm.php',form_data,SERVER,{'Cookie'=>@cookie},true)
    File.open("tmp/orderdidconfirm","w"){|f| f.write(body)}
    doc = Nokogiri::HTML.parse(body)
    number_confirm = doc.search("//table[@class='noticetable']//td").last.inner_text
    # brittle alert!
    number_confirm =~ /^- \d+ has been added to your account$/
  rescue NetUtil::InvalidResponseError => e
    if count < 1
      login(true)
      retry
    end
    raise e
  end
  
  def order(ratecenter, state,did=nil)
    first_did = available_dids(ratecenter,state).first if did.blank?
    raise "Unable to get DIDs" if first_did.blank?
    raise "Unable to order DID" unless pre_order(ratecenter,state,first_did)
    raise "Unable to cofirm order with provider" unless confirm_order(ratecenter, state, first_did)
    did_number = parse_provider_did(first_did)
    d = Did.new(phone_number: did_number,usage_state: Did::ACTIVE, state: state, city: ratecenter)
    d.save!
    d
  end
  
  def parse_provider_did(did)
    raise "Nothing to parse" if did.blank?
    # 4434513858:BALTIMORE:MD:0.99:0.01:0.50:4.95:1.00
    m = did.match(/(\d+)\:\w+/)
    m[1]
  end

end