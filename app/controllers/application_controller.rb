class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  before_filter :require_user
  
  layout "application"
  helper :all # include all helpers, all the time
  protect_from_forgery  # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  def self.call_states
    @states ||= lambda{ v = Voipms.new;v.states}.call
  end
  
  private
  def require_user
    # if json_request?
    #   current_user = User.from_email_phone_number(params[:email], params[:number])
    # end
    unless current_user
      # authenticate_with_http_basic do |email,number|
      #   current_user = User.from_email_phone_number(params[:email], params[:number])
      # end
      # return true if current_user
      
      respond_to do |format|
        format.html { session[:current] = store_location;redirect_to(login_url)}
        format.json { render :status => :forbidden, :json => {:message=>'Invalid user'} }
      end
      return false
    end
  end
  
  def json_request?
    content_type = request.headers['CONTENT_TYPE'] || request.headers['Content-Type']
    mime = Mime::Type.lookup(content_type)
    mime.to_sym == :json
  end
end
