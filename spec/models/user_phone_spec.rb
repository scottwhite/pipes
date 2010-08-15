require 'spec_helper'

describe UserPhone, "doing it" do
  before(:each) do
    setup_user
    DidsUserPhone.delete_all
    @phone = @user.phones.first
  end
  it "should order and assign number" do
    did = @phone.order_and_assign(city: 'baltimore',state: 'MD')
    @phone.dids.count.should == 1
    @phone.dids.first.usage_state == Did::IN_USE
  end
end