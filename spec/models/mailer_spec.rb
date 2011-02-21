require 'spec_helper'

describe Mailer do
  
  def build_call_queue( dup, email, queue_type=1,caller = '1234567890', calling = '0987654321')
    CallQueue.create(dids_user_phone_id: dup.id, caller: caller, calling: calling, queue_type: queue_type, email: email, call_time: 100, time_left: 200, start_date: Time.now)
  end
  
  before(:all) do
    @user = setup_user
    @user.phones.first.dids << Did.first
    @user.phones.first.save!
    
  end
  
  
  before(:each) do
    dup =  @user.phones.first.dids_user_phones.first
    build_call_queue(dup, @user.email,1)
    build_call_queue(dup,@user.email,2)
  end
  
  after(:each) do
    CallQueue.delete_all
  end
  
  it "should send an email for receiving a call after number has expired" do
    mail = Mailer.deliver_expired_notice(CallQueue.last)
    mail.body.should == "<html>\n<head>\n  <style>\n    p {\n      font-size: 1em;\n    },\n    .note{\n      font-size: 1em;\n    }\n    span.number {\n      font-weight: 'bold';\n    }\n  </style>\n</head>\n<body>\n  <p> Greetings!</p>\n  <p>You had a recent call from <span class=\"number\">123 456 7890 to your expired Pipes Number</p>\n  <p> The call lasted 1 minute and 40 seconds</p>\n  <p> If you'd like to re-up your Pipes Number please click <a href=\"http://bobo/existing/3\">here</a>\n  <p class=\"note\">If you have any questions please feel free to contact us.<br>\n    To no longer receive these messages, pleas click here to change your settings <a href=\"http://bobo/users/settings?token=aee710eee3831c28b7c2661379e2e366a884eb8a\">Email settings</a>\n  </p>\n</body>\n</html>"
  end
  
  it "should send an email after receiving a call when number is active" do
    mail = Mailer.deliver_recent_call_with_stats(CallQueue.first)
    mail.body.should == 'blah'
  end
  
  it "should resend the users pipes number" do
  end
end