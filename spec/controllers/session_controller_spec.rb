require 'spec_helper'

describe SessionsController do
  before(:all) do
    setup_user
  end
  
  it "should get a token" do
    User.stub(:make_token).and_return('superblah')
    get "request_token", {email: @user.email, number: @user.phones.first.number, format: 'json'}
    response.body.should == 'superblah'
  end
  
  it "shoudl error if invalid request for token" do
    get "request_token", {emai: @user.email, number: @user.phones.first.number, format: 'json'}
    response.status.should == '404 Not Found'
    body = ActiveSupport::JSON::decode(response.body)
    body.should == {"error"=>"no-record", "message"=>"email:  and number: #{@user.phones.first.number}"}
  end
end