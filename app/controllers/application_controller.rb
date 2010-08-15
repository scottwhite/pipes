class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  before_filter :logged_in?
  
  layout "application"
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
end
