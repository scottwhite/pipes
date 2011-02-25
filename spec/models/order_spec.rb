require 'spec_helper'

describe Order, "doing it" do
  before(:each) do
    setup_user
  end
  it "should create an order for a user" do
    o = Order.pipes_number(@user.phones.first)
    o.user_id.should == @user.id
    o.id.should_not be_blank
    o.product.should == Product.pipes_number
  end
  
  it "should process an order" do
    Did.stub!(:available_by_region).and_return([])
    o = Order.pipes_number(@user.phones.first)
    did = o.process({gateway_trans_id: 'blah', raw_status: 'Completed'})
    did.should_not be_nil
  end
  
  it "should order an extenstion" do
    o = Order.extend_pipes(@user.phones.first)
    o.product.should == Product.pipes_extend
  end
  
  it "should order a re-up" do
    o = Order.reup_pipes(@user.phones.first)
    o.product.should == Product.pipes_reup
  end
    
  it "should stale orders" do
    Order.nuke_unused
  end
end