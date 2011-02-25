class OrdersController < ApplicationController
  skip_before_filter :require_user, :verify_authenticity_token
  before_filter :verify, only: [:finialize]

  def finialize
    render text: "whatever", status: 403 if params[:test_ipn] && RAILS_ENV== 'production'
    did = @order.process({raw_status: params[:payment_status], gateway_trans_id: params[:txn_id]})
    if did.blank?
      render text: 'error, unable to process request',status: 500  && return
    end
    Mailer.deliver_order_completed(did,@order) if did && @order.user.email?
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
    # {"tx"=>"96C79327GK037281M", "st"=>"Completed", "amt"=>"3.00", "cc"=>"USD", "cm"=>"", "item_number"=>"order", 
    # unless (params[:payment_status]=="Completed" || params[:st] == 'Completed') && (!params[:txn_id].blank? || !params[:tx].blank?)
    unless params[:st] == 'Completed' && !params[:tx].blank?
      render action: 'fail'
    end
  end
  
  def fail
  end

  private
  def verify
    id = params[:id] || params[:invoice]
    @order = Order.verify(id.to_i)
  end
end