require 'spec_helper'

describe Did, "doing it" do
  before(:each) do
    setup_user
  end
  it "should return avialable numbers for a region, currently city and state" do
    avail = Did.available_by_region('baltimore','MD')
    avail.size.should == 4
  end
  
  it "should setup a number" do
    puts @user.inspect
    NetUtil::Request.stub!(:send).and_return('blah')
    r = Did.order(city: 'baltimore', state: 'md', user_phone: @user.phones.first)
    r.phone_number.should == '4434513859'
  end
  
end