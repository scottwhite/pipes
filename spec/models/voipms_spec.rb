require 'spec_helper'

describe Voipms, "doing it" do
  
  it "should read login info from file" do
    File.stub!(:read).and_return('{"username":"bobo", "password": "bubba"}')
    v = Voipms.new
    v.username.should == 'bobo'
    v.password.should == 'bubba'
  end
  
  it "should login and get cookie" do
    pending("hmmmm not good for CI")
    v = Voipms.new
    v.login(true)
    v.cookie.should =~ /PHPSESSID=\w+; path=\//
    File.exists?(Voipms::COOKIE_PATH).should == true
  end
  
  it "should re-use the cookie" do
    pending("not good for CI")
    NetUtil::Request.should_not_receive(:hack_session_cookie)
    v = Voipms.new
    v.login
    v.cookie.should =~ /PHPSESSID=\w+; path=\//
  end
  
  describe "logged in" do
    it "should parse a did" do
      v = Voipms.new
      number = v.parse_provider_did("4434513858:BALTIMORE:MD:0.99:0.01:0.50:4.95:1.00")
      number.should == '4434513858'
    end
    
    it "should get dids for a city and state" do
      v = Voipms.new
      v.login
      NetUtil::Request.stub(:send).and_return(['blah',File.read("#{RAILS_ROOT}/spec/fixtures/voip_ms_order_did.html")])
      dids = v.available_dids('baltimore','md')
      dids.should == ['4434513858:BALTIMORE:MD:0.99:0.01:0.50:4.95:1.00']
    end
    
    it "should pre order for a city and state" do
      # NetUtil::Request.stub(:send).and_return(['blah',File.read("#{RAILS_ROOT}/spec/fixtures/voip_ms_order_did.html")])
      NetUtil::Request.stub(:post).and_return(File.read("#{RAILS_ROOT}/spec/fixtures/voip_ms_order_did_step_2.html"))
      v = Voipms.new
      r = v.pre_order('baltimore','md','4434513859:BALTIMORE:MD:0.99:0.01:0.50:4.95:1.00')
      r.should == true
    end
    
    it "should confirm order for a city and state" do
      NetUtil::Request.stub(:post).and_return(File.read("#{RAILS_ROOT}/spec/fixtures/voip_ms_order_did_step_3.html"))
      v = Voipms.new
      r = v.confirm_order('baltimore','md','4434513859:BALTIMORE:MD:0.99:0.01:0.50:4.95:1.00')
      r.should == true
    end
    
    it "should do the order stack" do
      pending("need a better stub of regression")
      v = Voipms.new
      v.login
      d = v.order('baltimore','md')
      d.class.should == Did
      d.id.should_not be_nil
    end
    
    
  end
  
end
