require 'spec_helper'

describe DidsController do
  before(:each) do
    setup_user
    @user.phones.first.dids << Did.first
    @user.phones.first.save!
  end
  after(:each) do
    @user.phones.first.dids_user_phones.delete_all
  end
  
  it "should require a token" do
    get 'index', {format: 'json'}
    response.status.should == '403 Forbidden'
  end

  it "should work with a token" do
    @user.generate_token
    @user.save!
    t = @user.activation_code
    get 'index', {format: 'json', token: t}
    response.status.should == '200 OK'
  end
  
  
  it "should list users numbers" do
    # controller.stub!(:current_user).and_return(@user)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(@user.email,@user.phones.first.number)
    # User.should_receive(:from_email_and_phone_number).with(@user.email,@user.phones.first).and_return(mock_model(AuthUser, user_name: 'blah'))
    get 'index', {format: 'json'}
    dids = ActiveSupport::JSON::decode(response.body)
    dids.size.should == 1
    puts dids.inspect
    dids.first[:time_left].should == @user.current_dids.first[:time_left]
  end
end