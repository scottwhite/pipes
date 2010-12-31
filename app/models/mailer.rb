class Mailer < ActionMailer::Base
  PIPES = 'support@pipes.io'
  ActionMailer::Base.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => 587,
    :domain => "pipes.io",
    :authentication => :plain,
    :user_name => "scott",
    :password => "dPgZAqArDNjS3VRxl6s",
    :enable_starttls_auto => true
   }
  
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
end