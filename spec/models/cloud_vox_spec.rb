require 'spec_helper'

describe Voipms, "doing it" do  
  it "should search a number" do
    r = CloudVox.search(4436188250)
    r.should_not be_nil
    r['allocation'].should_not be_nil
  end
  
  it "should get the state and rate center for a number" do
    rc = CloudVox.state_rate_center(4436188250)
    rc[:ratecenter].should == 'GLENBURNIE'
    rc[:state].should == 'MD'
  end
end