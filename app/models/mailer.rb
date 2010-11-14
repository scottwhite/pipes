class Mailer < ActionMailer::Base
  PIPES = 'support@pipes.io'
  def order_completed(did,order)
    user = order.user
    recipients user.email
    from PIPES
    subject 'Order Processed'
    content_type 'text/html'
    body user: user, did: did
  end
end