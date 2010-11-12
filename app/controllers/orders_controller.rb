class OrdersController < ApplicationController
  skip_before_filter :require_user, :verify_authenticity_token
  before_filter :verify, only: [:finialize]

  def finialize
    did = @order.process({raw_status: params[:payment_status], gateway_trans_id: params[:txn_id]})
    Mailer.send_order_completed(did,@order) if did
    respond_to do |wants|
      wants.html{ render text: did.phone_number}
      wants.json{ render json: did.phone_number}
    end
  end
    
  def destroy
    
  end
  
  def index
    render text: 'what the '
  end
  
  def show
  end

  private
  def verify
    id = params[:id] || params[:invoice]
    @order = Order.verify(id.to_i)
  end
end