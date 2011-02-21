class Mailer < ActionMailer::Base
  PIPES = 'support@pipes.io'
  ActionMailer::Base.delivery_method = :sendmail
  
  def order_completed(did,order)
    user = order.user
    recipients user.email
    from PIPES
    subject 'Pipes Order Processed'
    content_type 'text/html'
    body user: user, did: did
  end
  
  def existing_did(did,user)
    @token = user.generate_token
    recipients user.email
    from PIPES
    subject 'Your Pipes number'
    content_type 'text/html'
    body user: user, did: did    
  end
  
  def recent_call_with_stats(call_queue)
    @dup = DidsUserPhone.find(call_queue.dids_user_phone_id)
    @token = @dup.user_phone.user.generate_token
    
    recipients call_queue.email
    from PIPES
    subject 'Recent call to your Pipes number'
    content_type 'text/html'
    body call_queue: call_queue
  end
  
  def expired_notice(call_queue)
    @dup = DidsUserPhone.find(call_queue.dids_user_phone_id)
    @token = @dup.user_phone.user.generate_token
    
    recipients call_queue.email
    from PIPES
    subject 'Recent call to your EXPIRED Pipes number'
    content_type 'text/html'
    body call_queue: call_queue
  end
  
end