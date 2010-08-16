class RequestNumberController < ApplicationController
  
  def new
    # new request for did
    respond_to do |wants|
      if @did = check_for_existing
        flash[:notice] = "Currently have a temporary number #{@did.friendly_phone_number}"
        wants.html { render }
        wants.json  { render json: @dids.first }
      else
        wants.html {}
      end
    end
  end
  
  def create
    phone = params[:user_phone]
    raise "must have phone" if phone.blank?
    respond_to do |wants|
      if @did = check_for_existing
        flash[:notice] = "Currently have a temporary number #{@did.friendly_phone_number}"
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