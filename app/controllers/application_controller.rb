class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  before_filter :require_user
  
  layout "application"
  helper :all # include all helpers, all the time
  protect_from_forgery  # See ActionController::RequestForgeryProtection for details

  
  rescue_from ActionController::UnknownAction do |error|
    logger.debug(error.message)
    logger.debug(error.backtrace.join("\n"))
    error_responds_to(nil,'cannot-process-request',:not_found)
  end
    
  rescue_from 'ActiveRecord::RecordNotFound' do |error|
    error_responds_to(error.message,'no-record',:not_found)
    return false
  end
  
  # rescue_from Exception do |error|
  #   logger.error("unhandled exception: #{error.message}\n" + error.backtrace.join("\n"))
  #   render(text: "An unknown error has occurred", status: 500)
  # end
  


  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  def self.call_states
    # @states ||= lambda{ v = Voipms.new;v.states}.call
  end
  
  protected
  def is_production?
    RAILS_ENV=='production'
  end
  
  def current_user
    @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie || login_from_token) unless @current_user == false
  end
  
  
  private
  
  def login_from_token
    # return nil if params[:token].blank?
    User.find_by_activation_code(params[:token] || params[:t])
  end
  
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
  
  def error_responds_to(message, error_type="cannot-process-request", status= :bad_request)
    if message.blank?
      head status: status
    else    
      respond_to do |wants|
        wants.json{ render json: {error: error_type, message: message}, status: status}
        wants.xml{ render xml: {error: error_type, message: message}.to_xml(root: 'response'), status: status}
      end
    end
  end
  
end
