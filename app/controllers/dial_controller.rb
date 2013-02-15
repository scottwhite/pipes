class DialController < ApplicationController
  def index

  end

  def token
    unless(params[:token].blank?)
      if(current_user.find_request_token(params[:token]))
        current_user.remove_request_token(params[:token])
        t = TwilioProvider.new
        begin
          did =current_user.current_dids.first
          dup = did.dup
          token = t.generate_capability_token(current_user)
        rescue => e
          console.log(e.message)
          redirect_to :index
        end
        render template: '/dial/webdial.html', locals: {token: token, dup: dup}
        return
      end
    else
      token = current_user.send_request_token  
    end
    

  end

  def call
  end
end