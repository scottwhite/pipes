require 'spec_helper'

describe Mailer do
  
  def build_call_queue( dup, email, queue_type=1,caller = '1234567890', calling = '0987654321')
    CallQueue.create(dids_user_phone_id: dup.id, caller: caller, calling: calling, queue_type: queue_type, email: email, call_time: 100, time_left: 200, start_date: Time.now)
  end
  
  def create_order
    Did.stub!(:available_by_region).and_return([])
    o = Order.pipes_number(@user.phones.first)
    did = o.process({gateway_trans_id: 'blah', raw_status: 'Completed'})
    did
  end
  
  before(:each) do
    @user = setup_user
    @user.phones.first.dids << Did.first
    @user.phones.first.save!
    User.stub(:make_token).and_return('superblah')
    @dup =  @user.phones.first.dids_user_phones.first
    build_call_queue(@dup, @user.email,1)
    build_call_queue(@dup,@user.email,2)
  end
  
  after(:each) do
    CallQueue.delete_all
    @user.phones.first.dids_user_phones.delete_all
  end
  
  it "should send an email for receiving a call after number has expired" do
    mail = Mailer.deliver_expired_notice(CallQueue.last)
    mail.body.should == "<html>\n<head>\n  <style>\n    p {\n      font-size: 1em;\n    },\n    .note{\n      font-size: 1em;\n    }\n    span.number {\n      font-weight: 'bold';\n    }\n  </style>\n</head>\n<body>\n  <p> Greetings!</p>\n  <p>You had a recent call from <span class=\"number\">123 456 7890 to your expired Pipes Number</p>\n  <p> The call lasted 1 minute and 40 seconds</p>\n  <p> If you'd like to re-up your Pipes Number please click <a href=\"http://bobo/existing/#{@dup.id}\">here</a></p>\n  <p class=\"note\">If you have any questions please feel free to contact us.<br>\n    To no longer receive these messages, pleas click here to change your settings <a href=\"http://bobo/users/settings?token=superblah\">Email settings</a>\n  </p>\n</body>\n</html>"
  end
  
  it "should send an email after receiving a call when number is active" do
    mail = Mailer.deliver_recent_call_with_stats(CallQueue.first)
    mail.body.should == "<html>\n<head>\n  <style>\n    p {\n      font-size: 1em;\n    },\n    .note{\n      font-size: 1em;\n    }\n    span.number {\n      font-weight: 'bold';\n    }\n  </style>\n</head>\n<body>\n  <p> Greetings!</p>\n  <p>You had a recent call from <span class=\"number\">123 456 7890</p>\n  <p> The call lasted 1 minute and 40 seconds</p>\n  <p> Reminder: You have 3 minutes and 20 seconds of talk time left until <span class=\"number\"></span></p>\n  <p> If you'd like to add more minutes or re-up your Pipes Number please click <a href=\"http://bobo/existing/#{@dup.id}\">here</a></p>\n  <p class=\"note\">If you have any questions please feel free to contact us.<br>\n    To no longer receive these messages, pleas click here to change your settings <a href=\"http://bobo/users/settings?token=superblah\">Email settings</a>\n  </p>\n</body>\n</html>"
  end
  
  it "should resend the users pipes number" do
  end
  
  it "should send the order completed for new" do
    order = Order.pipes_number(@user.phones.first)
    mail = Mailer.deliver_order_completed(Did.first,order)
    mail.body.should == "<html>\n<head>\n  <style>\n    p {\n      font-size: 1em;\n    },\n    .note{\n      font-size: 0.8em;\n    }\n    span.number {\n      font-weight: 'bold';\n    }\n  </style>\n</head>\n<body>\n  <p> Thank You!</p>\n  <p> Your order has been processed, your Pipes Number is <span=\"number\">443 482 5307</span></p>\n  <p class=\"note\">Remember you have 20 minutes total talk time for a total of 3 weeks</p>\n</body>\n</html>"
  end

  it "should send the order completed for extend" do
    did = create_order
    order = Order.extend_pipes(@user.phones.first)
    order.process({gateway_trans_id: 'blah', raw_status: 'Completed'})
    mail = Mailer.deliver_order_completed(did,order)
    mail.body.should == "<html>\n<head>\n  <style>\n    p {\n      font-size: 1em;\n    },\n    .note{\n      font-size: 0.8em;\n    }\n    span.number {\n      font-weight: 'bold';\n    }\n  </style>\n</head>\n<body>\n  <p> Thank You!</p>\n  <p> You have added 30 minutes, for a total talk time of 50 minutes which expires on March 14, 2011.</p>\n</body>\n</html>"
  end
  
  it "should send the order completed for re-up" do
    did = create_order
    order = Order.reup_pipes(@user.phones.first)
    order.process({gateway_trans_id: 'blah', raw_status: 'Completed'})
    mail = Mailer.deliver_order_completed(did,order)
    mail.body.should == "<html>\n<head>\n  <style>\n    p {\n      font-size: 1em;\n    },\n    .note{\n      font-size: 0.8em;\n    }\n    span.number {\n      font-weight: 'bold';\n    }\n  </style>\n</head>\n<body>\n  <p> Thank You!</p>\n  <p> Your order has been processed, your Pipes Number (<span=\"number\">443 482 5307</span>)<br>\n    now has a total talk time of 40 minutes which expires on April 04, 2011\n    </p>\n</body>\n</html>"
  end
  
end