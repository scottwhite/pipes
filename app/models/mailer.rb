class Mailer < ActionMailer::Base
  PIPES = 'support@pipes.io'
  ActionMailer::Base.delivery_method = :sendmail
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
  
  def existing_did(did,user)
    token = user.generate_token
    recipients user.email
    from PIPES
    subject 'Your Pipes number'
    content_type 'text/html'
    body user: user, did: did, token: token
  end
  
  def recent_call_with_stats(call_queue)
    dup = DidsUserPhone.find(call_queue.dids_user_phone_id)
    token = setup_token(dup)
    
    recipients call_queue.email
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