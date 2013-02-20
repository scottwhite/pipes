class Mailer < ActionMailer::Base
  PIPES = 'support@pipes.io'
  # ActionMailer::Base.delivery_method = :sendmail
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.raise_delivery_errors = false
  ActionMailer::Base.default_charset = "utf-8"
  ActionMailer::Base.smtp_settings = {
      :address => "email-smtp.us-east-1.amazonaws.com",
      :user_name => "AKIAJVKGOU4JDKMBYXPQ",
      :password => "ApscaI3hfM98oQu7UfAn9isf6H3CSpvG6exm/3j4n53q",
      :authentication => :login,
      :domain             => "pipes.io"
  }
  layout 'email'
  
  def order_completed(did,order)
    user = order.user
    dup = DidsUserPhone.find(:first, conditions: {expire_state: 0, did_id: did.id, user_phone_id: order.user_phone_id})
    recipients user.email
    from PIPES
    subject 'Pipes Order Processed'
    content_type 'text/html'
    body user: user, did: did, order: order, dup: dup
  end
  
  def user_token(user)
    recipients user.email
    from PIPES
    subject 'Pipes - Authentication link'
    content_type 'text/html'
    body user: user
  end

  def existing_did(did,user)
    token = user.generate_token
    recipients user.email
    from PIPES
    subject 'Your Pipes number'
    content_type 'text/html'
    body user: user, did: did, token: token
  end
  
  def recent_call_with_stats(call_data)
    user = User.find_by_user_id(call_data['user_id'])
    return if user.blank?
    dup = DidsUserPhone.find(call_data['user_id'])

    token = setup_token(dup)
    
    recipients call_data.email
    from PIPES
    subject 'Recent call to your Pipes number'
    content_type 'text/html'
    body call_queue: call_queue, token: token, dup: dup, did: dup.did
  end
  
  def expired_notice(call_queue)
    dup = DidsUserPhone.find(call_queue.dids_user_phone_id)
    token = setup_token(dup)
    
    recipients call_queue.email
    from PIPES
    subject 'Recent call to your EXPIRED Pipes number'
    content_type 'text/html'
    body call_queue: call_queue, token: token, dup: dup
  end
  
  def setup_token(dup)
    user = dup.user_phone.user
    token = user.generate_token
    user.save!
    token
  end
  
end