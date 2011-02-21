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
  
  it "should list users numbers" do
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(@user.email,@user.phones.first.number)
    # User.should_receive(:from_email_and_phone_number).with(@user.email,@user.phones.first).and_return(mock_model(AuthUser, user_name: 'blah'))
    get 'index', {format: 'json'}
    dids = ActiveSupport::JSON::decode(response.body)
    dids.size.should == 1
    dids.first[:time_left].should == @user.current_dids.first[:time_left]
  end
end