require 'spec_helper'


describe CallQueue do
  it "should format time for displaying" do
    CallQueue.format_seconds(40).should == '40 seconds'
    CallQueue.format_seconds(1100).should == '18 minutes and 20 seconds' 
    CallQueue.format_seconds(0).should == '0 seconds'
    CallQueue.format_seconds(1).should == '1 second'
    CallQueue.format_seconds(60).should == '1 minute'
    CallQueue.format_seconds(61).should == '1 minute and 1 second'
  end
  
  it "should format call_time" do
    cq = CallQueue.new(call_time: 800)
    cq.formatted_call_time.should == "13 minutes and 20 seconds"
  end

  it "should format call_time" do
    cq = CallQueue.new(time_left: 800)
    cq.formatted_time_left.should == "13 minutes and 20 seconds"
  end
  
end