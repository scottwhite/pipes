# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  skip_before_filter :require_user, except: [:destory]
  
  # render new.html.erb
  def new
    @states = self.class.call_states
  end

  def create
    logout_keeping_session!
    phone =params[:user_phone]
    @user = User.find_or_initialize_by_email(params[:email])
    @user.phones.build(number: phone) unless @user.phones.exists?(number: UserPhone.convert_number(phone))
    if @user.save
      reset_session
      session[:current_order] = {phone: phone}
      self.current_user = @user
      flash.discard
      redirect_back_or_default("/request_number/new")
    else
      flash[:error] = @user.errors.full_messages.join('<br>')
      # note_failed_signin
      @email       = params[:email]
      @user_phone = params[:user_phone]
      @remember_me = params[:remember_me]
      @city = params[:city]
      @state = params[:state]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
