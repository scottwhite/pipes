class Mailer < ActionMailer::Base
  PIPES = 'support@pipes.io'
  def order_completed(did,order)
    user = order.user
    to user.email
    from PIPES
    subject 'Order Processed'
    body user: user, did: did
  end
end