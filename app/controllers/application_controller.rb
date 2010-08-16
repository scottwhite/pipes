class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  before_filter :require_user
  
  layout "application"
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  private
  def require_user
    unless current_user
      respond_to do |format|
        format.html { session[:current] = store_location;redirect_to(login_url)}
        format.json { render :status => :forbidden, :json => {:message=>'not logged in'} }
      end
      return false
    end
  end
end
