require 'spec_helper'

describe Order, "doing it" do
  before(:each) do
    setup_user
  end
  it "should create an order for a user" do
    o = Order.create_for(@user)
    o.user_id.should == @user.id
    o.id.should_not be_blank
  end
    
end