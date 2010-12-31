class RequestNumberController < ApplicationController
  
  def new
    # new request for did
    respond_to do |wants|
      @user_order = session[:current_order]
      if @did = check_for_existing
        flash[:notice] = "Currently have a temporary number, would you like it re-sent?"
        wants.html { render action: "new" }
        wants.json  { render json: @dids.first }
      else
        @order= Order.create_for(current_user, session[:current_order])
        wants.html { render }
      end
    end
  end
  
  def mail_existing
    did = check_for_existing
    if did.blank?
      flash[:status] = "There is a problem, you requested to email your existing Pipes number but you don't have one"
    else
      Mailer.existing_did(did,current_user)
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
    @did = Did.find(params[:id])
    respond_to do |wants|
      wants.html {}
      wants.json  { render json: @dids.first }
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