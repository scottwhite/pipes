require 'spec_helper'

describe DidsUserPhone do
  before(:each) do
    setup_user
    @phone = @user.phones.first
  end
  it "get dup by did number" do
    did = @phone.order_and_assign
    did2 = DidsUserPhone.by_did_number(did.phone_number)
    dids2.first.shoudl == did.dids_user_phone
  end
end