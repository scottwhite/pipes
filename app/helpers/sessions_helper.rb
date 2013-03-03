module SessionsHelper
    def is_mobile?
        return (/Mobile/.match(request.env["HTTP_USER_AGENT"]) != nil)
    end
end