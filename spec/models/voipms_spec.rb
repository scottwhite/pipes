require 'spec_helper'

describe Voipms, "doing it" do  
  
  describe "XML API" do
    before(:all) do
      @client = Voipms.new
    end
    it "should get balance" do
      response = @client.get_balance
      response.current_balance
    end
    it "should get a valid DID" do
      response = @client.available_dids
      response.should == 'blah'
    end
    it "should order a DID" do
      r = @client.order("BALTIMORE","MD")
      d = Did.last
      r.should == d
    end
    
  end
  
  it "should read login info from file" do
    File.stub!(:read).and_return('{"username":"bobo", "password": "bubba"}')
    v = Voipms.new
    v.username.should == 'bobo'
    v.password.should == 'bubba'
  end
  
  
end
