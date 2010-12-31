require 'spec_helper'

describe UserPhone, "doing it" do
  before(:each) do
    setup_user
    DidsUserPhone.delete_all
    @phone = @user.phones.first
  end
  it "should order and assign number" do
    pending("what what")
    did = @phone.order_and_assign(city: 'baltimore',state: 'MD')
    @phone.dids.count.should == 1
    @phone.dids.first.usage_state == Did::IN_USE
  end
  VALID_NUMBERS = ['123 456 7890', '(123) 456-7890','(123 456-7890', '123-456-7890', '1234567890']
  INVALID_NUMBER = ['12 456 7890', '456-7890', '4567890', '456 7890']
  describe "valid phone numbers" do
    VALID_NUMBERS.each do |vn|
      it "should validate phone number of #{vn}" do
        u = UserPhone.new(number: vn)
        u.valid?.should == true
      end
    end
  end
  describe "invalid phone numbers" do
    INVALID_NUMBER.each do |bn|
      it "should invalidate phone number of #{bn}" do
        u = UserPhone.new(number: bn)
        u.valid?.should == false
      end
    end
  end
  
end