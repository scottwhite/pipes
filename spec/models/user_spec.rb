require 'spec_helper'

describe User do
  before(:all) do
    setup_user
  end
  
  it "should find a user by email and phone number" do
    # @user = User.new(login: 'bobo', email: 'bobo@email.com')
    # @user.phones << UserPhone.new(number: '4436188250')
    
    u = User.from_email_and_phone_number('bobo@email.com', '4436188250')
    @user.should == u
  end
end