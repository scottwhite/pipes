require 'spec_helper'

describe OrdersController do
  before(:each) do
    setup_user
    controller.stub!(:current_user).and_return(@user)
  end
  
  it "should process an order " do
    o = Order.pipes_number(@user)
    Order.should_receive(:find).with(o.id).and_return(o)
    did = mock_model(Did, phone_number: '123 456 7890')
    o.should_receive(:process).with({raw_status: 'Completed', gateway_trans_id: "6KP172393Y976771E"}).and_return(did)
    post 'finialize', {format: 'json', "order"=> o.id, "mc_gross"=>"3.00", "protection_eligibility"=>"Ineligible", "payer_id"=>"LK8P5A9FDY3X4", "tax"=>"0.00", "payment_date"=>"07:37:21 Nov 12, 2010 PST", "payment_status"=>"Completed", "charset"=>"windows-1252", "first_name"=>"Test", "mc_fee"=>"0.39", "notify_version"=>"3.0", "custom"=>"", "payer_status"=>"unverified", "business"=>"scott_1289574243_biz@pipes.io", "quantity"=>"1", "verify_sign"=>"A.1fLsI0bz.u5Y-Je2kykV2Y6dlHAAQSvAuw-2njspjXQ35G60kSpVIA", "payer_email"=>"scott_1289571448_per@pipes.io", "txn_id"=>"6KP172393Y976771E", "payment_type"=>"instant", "btn_id"=>"1327123", "last_name"=>"User", "receiver_email"=>"scott_1289574243_biz@pipes.io", "payment_fee"=>"0.39", "shipping_discount"=>"0.00", "insurance_amount"=>"0.00", "receiver_id"=>"MSFGYAZ7YNB7U", "txn_type"=>"web_accept", "item_name"=>"Pipes Number", "discount"=>"0.00", "mc_currency"=>"USD", "item_number"=>"order", "residence_country"=>"US", "test_ipn"=>"1", "handling_amount"=>"0.00", "shipping_method"=>"Default", "transaction_subject"=>"Pipes Number", "payment_gross"=>"3.00", "shipping"=>"0.00"}
  end
  

  it "should process an UPDATED API order" do
    o = Order.pipes_number(@user)
    Order.should_receive(:find).with(o.id).and_return(o)
    did = mock_model(Did, phone_number: '123 456 7890')
    o.should_receive(:process).with({raw_status: 'Completed', gateway_trans_id: "6KP172393Y976771E"}).and_return(did)
    post 'finialize', {"payment_request_date"=>"Thu Feb 14 11:47:58 PST 2013", "return_url"=>"http://www.paypal.com", "fees_payer"=>"EACHRECEIVER", "ipn_notification_url"=>"http://test.pipes.io/orders/86/finialize", "verify_sign"=>"An5ns1Kso7MWUdW4ErQKJJJ4qi4-AdJXlUI5Rf5AJJwhDAVN6Lb.ZxYf", "test_ipn"=>"1", "transaction"=>{"0"=>{".id_for_sender_txn"=>"44C810198M239930H", ".receiver"=>"test_1340318307_biz@pipes.io", ".is_primary_receiver"=>"false", ".id"=>"7N900239D5060901Y", ".status"=>"Completed", ".paymentType"=>"SERVICE", ".status_for_sender_txn"=>"Completed", ".pending_reason"=>"NONE", ".amount"=>"USD 3.00"}}, "cancel_url"=>"http://www.paypal.com", "pay_key"=>"AP-03U059633G226072F", "action_type"=>"CREATE", "transaction_type"=>"Adaptive Payment PAY", "status"=>"COMPLETED", "log_default_shipping_address_in_transaction"=>"false", "charset"=>"windows-1252", "sender.useCredentials"=>"true", "notify_version"=>"UNVERSIONED", "reverse_all_parallel_payments_on_error"=>"false", "id"=>"86"}
  end

  it "should fail on dup order" do
    o = Order.pipes_number(@user)
    o.status = Order::COMPLETED
    o.save
    Order.should_receive(:find).with(o.id).and_return(o)
    # did = mock_model(Did, phone_number: '123 456 7890')
    o.should_not_receive(:process)
    post 'finialize', {format: 'json', "order"=> o.id, "mc_gross"=>"3.00", "protection_eligibility"=>"Ineligible", "payer_id"=>"LK8P5A9FDY3X4", "tax"=>"0.00", "payment_date"=>"07:37:21 Nov 12, 2010 PST", "payment_status"=>"Completed", "charset"=>"windows-1252", "first_name"=>"Test", "mc_fee"=>"0.39", "notify_version"=>"3.0", "custom"=>"", "payer_status"=>"unverified", "business"=>"scott_1289574243_biz@pipes.io", "quantity"=>"1", "verify_sign"=>"A.1fLsI0bz.u5Y-Je2kykV2Y6dlHAAQSvAuw-2njspjXQ35G60kSpVIA", "payer_email"=>"scott_1289571448_per@pipes.io", "txn_id"=>"6KP172393Y976771E", "payment_type"=>"instant", "btn_id"=>"1327123", "last_name"=>"User", "receiver_email"=>"scott_1289574243_biz@pipes.io", "payment_fee"=>"0.39", "shipping_discount"=>"0.00", "insurance_amount"=>"0.00", "receiver_id"=>"MSFGYAZ7YNB7U", "txn_type"=>"web_accept", "item_name"=>"Pipes Number", "discount"=>"0.00", "mc_currency"=>"USD", "item_number"=>"order", "residence_country"=>"US", "test_ipn"=>"1", "handling_amount"=>"0.00", "shipping_method"=>"Default", "transaction_subject"=>"Pipes Number", "payment_gross"=>"3.00", "shipping"=>"0.00"}
  end


  it "should fail if production and test order" do
    o = Order.pipes_number(@user.phones.first)
    Order.should_receive(:find).with(o.id).and_return(o)
    did = mock_model(Did, phone_number: '123 456 7890')
    o.should_not_receive(:process).with({raw_status: 'Completed', gateway_trans_id: "6KP172393Y976771E"}).and_return(did)
    controller.stub(:is_production?).and_return(true)
    post 'finialize', {format: 'json', "invoice"=> o.id,'test_ipn'=>1, "mc_gross"=>"3.00", "protection_eligibility"=>"Ineligible", "payer_id"=>"LK8P5A9FDY3X4", "tax"=>"0.00", "payment_date"=>"07:37:21 Nov 12, 2010 PST", "payment_status"=>"Completed", "charset"=>"windows-1252", "first_name"=>"Test", "mc_fee"=>"0.39", "notify_version"=>"3.0", "custom"=>"", "payer_status"=>"unverified", "business"=>"scott_1289574243_biz@pipes.io", "quantity"=>"1", "verify_sign"=>"A.1fLsI0bz.u5Y-Je2kykV2Y6dlHAAQSvAuw-2njspjXQ35G60kSpVIA", "payer_email"=>"scott_1289571448_per@pipes.io", "txn_id"=>"6KP172393Y976771E", "payment_type"=>"instant", "btn_id"=>"1327123", "last_name"=>"User", "receiver_email"=>"scott_1289574243_biz@pipes.io", "payment_fee"=>"0.39", "shipping_discount"=>"0.00", "insurance_amount"=>"0.00", "receiver_id"=>"MSFGYAZ7YNB7U", "txn_type"=>"web_accept", "item_name"=>"Pipes Number", "discount"=>"0.00", "mc_currency"=>"USD", "item_number"=>"order", "residence_country"=>"US", "test_ipn"=>"1", "handling_amount"=>"0.00", "shipping_method"=>"Default", "transaction_subject"=>"Pipes Number", "payment_gross"=>"3.00", "shipping"=>"0.00"}
    response.status.should == '403 Forbidden'
  end

end
