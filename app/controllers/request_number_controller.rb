class RequestNumberController < ApplicationController
  skip_before_filter :require_user, only: [:new, :existing, :existing_options]

  def new
    # new request for did
    respond_to do |wants|
      if current_user
        @user_order = session[:current_order]
        if @did = check_for_existing
          wants.html { redirect_to existing_path(@did.dids_user_phone.id) }
          wants.json  { render json: @did }
        else
          phone = current_user.phones.find_by_number(UserPhone.convert_number(@user_order[:phone]))
          @order= Order.create_for(phone,Product.pipes_number)
          wants.html { render }
          wants.json  { render json: @order}
        end
      elsif params[:format] == 'json'
        authenticate_with_http_basic do |email,phone|
          user = User.from_email_and_phone_number(email, phone)
          if user.blank?
            user = User.find_or_initialize_by_email(email)
            user.phones.build(number: phone) unless user.phones.exists?(number: UserPhone.convert_number(phone))
            user.save!
          end
          logger.debug(user.inspect)
          p = user.phones.find_by_number(UserPhone.convert_number(phone))
          order= Order.create_for(p,Product.pipes_number)
          wants.json  { render json: order}
        end
      end
    end
  end
  
  def existing
    if params[:id] || params[:did]
      
      @dup = DidsUserPhone.find(params[:id]) if params[:id]
      @dup = DidsUserPhone.by_did_number(UserPhone.convert_number(params[:did])).first if params[:did]
      unless current_user.blank? || @dup.user_phone.user_id == current_user.id 
        redirect_to(action: 'new')
        return
      end
      @did = @dup.did
      if @did.expired? && !@did.can_reup?
        render action: 'new' && return 
      end
      @from_mailing = params[:id].blank?
      @reup_order = Order.reup_pipes(@dup.user_phone)
      @ext_order = Order.extend_pipes(@dup.user_phone)
    end
  end
  
  def existing_options
    current_user = User.from_email_and_phone_number(params[:email],params[:number])
    raise ActiveRecord::RecordNotFound.new("nope") if current_user.blank?
    dup = DidsUserPhone.by_did_number(UserPhone.convert_number(params[:id])).first
    raise ActiveRecord::RecordNotFound.new("nope") unless dup
    unless dup.user_phone.user_id == current_user.id 
      render(json: 'Not allowed', status: 403)
      return
    end
    @did = dup.did
    @reup_order = Order.reup_pipes(dup.user_phone)
    @ext_order = Order.extend_pipes(dup.user_phone)
    @from_mailing = true
    render(template: 'request_number/_existing_options',layout: false)
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
    dids = current_user.current_dids
    unless dids.blank?
      dids.first
    end
  end  
end