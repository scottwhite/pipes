require 'spec_helper'

describe RequestNumberController do
  {"mc_gross"=>"3.00", "protection_eligibility"=>"Ineligible", "payer_id"=>"LK8P5A9FDY3X4", "tax"=>"0.00", "payment_date"=>"07:37:21 Nov 12, 2010 PST", "payment_status"=>"Completed", "charset"=>"windows-1252", "first_name"=>"Test", "mc_fee"=>"0.39", "notify_version"=>"3.0", "custom"=>"", "payer_status"=>"unverified", "business"=>"scott_1289574243_biz@pipes.io", "quantity"=>"1", "verify_sign"=>"A.1fLsI0bz.u5Y-Je2kykV2Y6dlHAAQSvAuw-2njspjXQ35G60kSpVIA", "payer_email"=>"scott_1289571448_per@pipes.io", "txn_id"=>"6KP172393Y976771E", "payment_type"=>"instant", "btn_id"=>"1327123", "last_name"=>"User", "receiver_email"=>"scott_1289574243_biz@pipes.io", "payment_fee"=>"0.39", "shipping_discount"=>"0.00", "insurance_amount"=>"0.00", "receiver_id"=>"MSFGYAZ7YNB7U", "txn_type"=>"web_accept", "item_name"=>"Pipes Number", "discount"=>"0.00", "mc_currency"=>"USD", "item_number"=>"order", "residence_country"=>"US", "test_ipn"=>"1", "handling_amount"=>"0.00", "shipping_method"=>"Default", "transaction_subject"=>"Pipes Number", "payment_gross"=>"3.00", "shipping"=>"0.00"}

  #Delete this example and add some real ones
  it "should use " do
    controller.should be_an_instance_of(RequestNumberController)
  end

end
