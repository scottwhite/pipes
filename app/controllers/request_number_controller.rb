class RequestNumberController < ApplicationController
  
  def new
    # new request for did
    respond_to do |wants|
      @user_order = session[:current_order]
      if @did = check_for_existing
        wants.html { render action: "existing" }
        wants.json  { render json: @dids.first }
      else
        phone = current_user.phones.find_by_number(UserPhone.convert_number(@user_order[:phone]))
        @order= Order.create_for(phone,@user_order)
        wants.html { render }
      end
    end
  end
  
  def existing
    if params[:token]
      @did = User.did_from_token(params[:token])
      @from_mailing = true 
    end
  end
  
  def mail_existing
    did = check_for_existing
    if did.blank?
      flash[:status] = "There is a problem, you requested to email your existing Pipes number but you don't have one"
    else
      Mailer.deliver_existing_did(did,current_user)
      flash[:status] = "Your Pipes number has been sent to your email address"
    end
  end
  
  def create
    phone =  session[:current_phone]
    
    respond_to do |wants|
      if @did = check_for_existing
        flash[:notice] = "Currently have a temporary number, would you like it re-sent?"
        wants.html { render action: "new" }
        wants.json  { render json: @dids.first }
      elsif @did = current_user.request_number(phone)
        wants.html { redirect_to success_request_number_path(@did) }
        wants.json  { render json: @did, status: :created, location: @did }
      else
        wants.html { render action: "new" }
        wants.json  { render json: @did.errors, status: :unprocessable_entity }
      end
    end
    
  end
  
  def success
    id = params[:id] || params[:invoice]
    @order= Order.find(id)
    if params[:payment_status]=="Completed"
      respond_to do |wants|
        wants.html {}
        wants.json  { render json: @dids.first }
      end
    else
      render action: 'fail'
    end
  end
  
  def fail
    respond_to do |wants|
      wants.html {}
      wants.json  { render json: {message: 'Did not get a successful response from Paypal'} }
    end
  end
  
  def show
  end
  
  def destory
  end
  private
  
  def check_for_existing
    dids = current_user.currently_using_dids
    dids.first unless dids.blank?
  end  
end