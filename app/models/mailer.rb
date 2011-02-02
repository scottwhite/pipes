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
    recipients user.email
    from PIPES
    subject 'Your Pipes number'
    content_type 'text/html'
    body user: user, did: did    
  end
  
  def recent_call_with_stats(call_queue)
    recipients call_queue.email
    from PIPES
    subject 'Recent call to your Pipes number'
    content_type 'text/html'
    body call_queue: call_queue
  end
end