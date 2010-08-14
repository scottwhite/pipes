module AuthenticatedTestHelper
  def log_in
    users = Users.make
    @request.session[:users_id] = users.id
  end

  def authorize
    users = Users.make
    @request.env["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic.encode_credentials(users.login, users.password)
  end
  
end
