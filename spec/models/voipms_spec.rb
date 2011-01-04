require 'spec_helper'

describe Voipms, "doing it" do  
  
  describe "XML API" do
    before(:all) do
      @client = Voipms.new
    end
    it "should get balance" do
      response = @client.balance
      response.current_balance
    end
    
    it "should get a list of ratecenters" do
      response = @client.ratecenters('md')
      response.should == 'blah'
    end

    it "should get the available ratecenters" do
      response = @client.available_ratecenters('md')
      response.should_not be_blank
    end

    it "should get the first available ratecenter" do
      response = @client.first_available_ratecenter('md')
      response.ratecenter.should_not be_nil
      response.available.should == 'yes'
    end
    
    it "should get a valid DID" do
      rc = @client.first_available_ratecenter('md')
      response = @client.available_dids(rc.ratecenter)
      response.should == 'blah'
    end
    
    it "should order a DID" do
      r = @client.order(nil,"MD")
      d = Did.last
      r.should == d
    end
    
    it "should get a list of states" do
      r = @client.states
      r.should == 'blah'
    end
    
  end
  
  it "should read login info from file" do
    File.stub!(:read).and_return('{"username":"bobo", "password": "bubba"}')
    v = Voipms.new
    v.username.should == 'bobo'
    v.password.should == 'bubba'
  end
  
  
end
