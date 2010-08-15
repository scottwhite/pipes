class RequestNumberController < ApplicationController
  before_filter :logged_in?
  
  def new
    # new request for did
    
  end
  
  def create
    phone = params[:user_phone]
    logger.debug(phone.inspect)
    current_user.request_number(phone)
    respond_to do |wants|
      if @did = current_user.request_number(phone)
        flash[:notice] = 'Request processed successfully.'
        wants.html { redirect_to(@did) }
        wants.json  { render json: @did, status: :created, location: @user_phone }
      else
        wants.html { render action: "new" }
        wants.json  { render json: @did.errors, status: :unprocessable_entity }
      end
    end
    
  end
  
  def show
  end
  
  def destory
  end
  
end