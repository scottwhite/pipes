class OrdersController < ApplicationController
  before_filter :verify, only: [:finialize]

  def finialize
    did = @order.process({raw_status: params[:payment_status], gateway_trans_id: params[:txn_id]})
    respond_to do |wants|
      wants.html{ redirect_to '/'}
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
    id = params[:id] || params[:order]
    @order = Order.verify(id.to_i)
  end
end