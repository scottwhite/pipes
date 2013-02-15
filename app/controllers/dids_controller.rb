class DidsController < ApplicationController
  before_filter :find_did, except: [:index, :history]
  
  rescue_from ActiveRecord::RecordNotFound do |error|
    error_responds_to(error.message,'no-record',:not_found)
  end
  
  
  def index
    dids = current_user.current_dids(include: :dids_phone_number)
    data = dids.map do |did|
      dup = did.dids_user_phone
      {dup_id: dup.id, did_id: did.id, expired: did.expired?, 
        can_reup: did.can_reup? , 
        time_allotted: dup.time_allotted, 
        time_left: dup.time_left, 
        expiration_date: dup.expiration_date, 
        number: did.phone_number}
    end
    
    respond_to do |wants|
      wants.html {render text: data}
      wants.json {render json: data}
    end
  end
  
  def show
    dup = @did.dids_user_phone
    data = {time_left: dup.time_left, expiration_date: dup.expiration_date, number: @did.phone_number} unless dup.blank?
    
    respond_to do |wants|
      wants.html {render text: did}
      wants.json {render json: data}
    end    
  end

  # need to figure out hwo to show stuff on website with token
  def history
    dup = current_user.current_dup
    if(number = dup.first)
        render json: CallLog.by_pipes_number(number)
    else
      render json:[]
    end
    
  end
    
  private
  def find_did
    @did = Did.find(params[:id],:include=>[:dids_user_phone])
  end
  
  def check_user_request
    
  end
end