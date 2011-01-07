require 'cgi'
require 'net/http'
require 'net/https'
module NetUtil
  class InvalidResponseError < Exception
  end
# Class to hold the base request to interact with the HTTP web services
  class Request    
    attr_accessor :port, :host, :timeout, :number_retries, :path, :header
        
    def send(path,params)
      server_opts={:host=>@host,:port=>@port,:timeout=>@timeout,:number_retries=>@number_retries}
      self.class.send(path,params,server_opts,header)
    end
                    
    class << self
      
      def convert_opt(option)
        unless option
          0
        else
          option.to_i
        end
      end
          
      def send(path,params,server_opts={},header={},ignore_302s=false)
        data = nil
        query_string = build_query_string(params)
        logger.debug("have query strings #{query_string}")
        url = if query_string
            "#{path}?#{query_string}"
        else
          path
        end
        logger.debug("send: url is #{url}")
        number_retries =convert_opt(server_opts[:number_retries])
        timeout = convert_opt(server_opts[:timeout])        
        begin
          count = (count)?+1:0
          response = nil
          logger.debug("send: hearders are #{header.inspect}")
          http = setup_http(server_opts)
          response,data = http.start{|h_session|
            h_session.read_timeout=timeout
            h_session.get2(url,header)
          }
          logger.debug("send: location is #{response['location']}")
          logger.debug("send: have response #{response}")
          check_http_response(response,ignore_302s)
          logger.debug("send: have response #{response.content_type}")
        rescue Exception => e
          logger.error("send: #{e.message}")
          if [Timeout::Error].include?(e.class)
            logger.error("read timeout is set to #{timeout}")
            if count < number_retries
              logger.debug("send: retrying")
              retry 
            end
          end
          logger.error(e)
          raise e
        end
        logger.debug("send: exit")
        data
      end

      def post(path,data,server_opts={},header={},ignore_302s=false)
        body = nil
        form_data = build_query_string(data)
        logger.debug("have query strings #{form_data}")
        logger.debug("hack_session_cookie: url is #{path}")
        number_retries =convert_opt(server_opts[:number_retries])
        timeout = convert_opt(server_opts[:timeout])
        begin
          count = (count)?count+1:0
          response = nil
          http = setup_http(server_opts)
          init_header = {'Content-Type' => 'application/x-www-form-urlencoded'}
          init_header.merge!(header) unless header.nil?
          response,body = http.start{|h_session|
            h_session.post2(path, form_data,init_header)
          }
          logger.debug("post: have response #{response.inspect}")
          logger.debug("post: location is #{response['location']}")
          check_http_response(response,ignore_302s)
          logger.debug("post: have response #{response.content_type}")
        rescue Exception => e
          logger.error("post: #{e.message}")
          if [Timeout::Error].include?(e.class)
            logger.error("read timeout is set to #{timeout}")
            if count < number_retries
              logger.debug("send: retrying")
              retry 
            end
          end
          logger.error(e)
          raise e
        end
        body
      end

      def post_data(path,data,server_opts={},header={})
        number_retries =convert_opt(server_opts[:number_retries])
        timeout = convert_opt(server_opts[:timeout])
        begin
          count = (count)?+1:0
          response = nil
          http = setup_http(server_opts)
          logger.debug("post_data: #{data}  #{header.inspect}")
          response,body = http.request_post(path,data,header)
          logger.debug("post_data: have response #{response.inspect} #{body}")
          check_http_response(response)
          logger.debug("post_data: have response #{response.content_type}")
        rescue Exception => e
          logger.error("post_data: #{e.message}")
          if [Timeout::Error].include?(e.class)
            logger.error("read timeout is set to #{timeout}")
            if count < number_retries
              logger.debug("post_data: retrying")
              retry
            end
          end
          logger.error(e)
          raise e
        end
        body
      end
      
      def hack_session_cookie(path,login_data,server_opts={},header={})
        data = nil
        form_data = build_query_string(login_data)
        logger.debug("have query strings #{form_data}")
        logger.debug("hack_session_cookie: url is #{path}")
        number_retries =convert_opt(server_opts[:number_retries])
        timeout = convert_opt(server_opts[:timeout])        
        cookie =nil
        begin
          count = (count)?+1:0
          response = nil
          http = setup_http(server_opts)
          response,data = http.start{|h_session|
            h_session.post2(path, form_data,{'Content-Type' => 'application/x-www-form-urlencoded'})
          }
          cookie = response.response['set-cookie']
          logger.debug("hack_session_cookie: have response #{data.inspect}")
          logger.debug("hack_session_cookie: have cookie #{cookie}")
          raise InvalidResponseError.new("Did not get a valid response, #{response.inspect}") unless cookie
          logger.debug("hack_session_cookie: have response #{response.content_type}")
        rescue Exception => e
          logger.error("hack_session_cookie: #{e.message}")
          if [Timeout::Error].include?(e.class)
            logger.error("read timeout is set to #{timeout}")
            if count < number_retries
              logger.debug("send: retrying")
              retry 
            end
          end
          logger.error(e)
          raise e
        end
        cookie
      end

      def check_http_response(response,ignore_302s=false)
        unless response.is_a?(Net::HTTPSuccess)
          unless response.is_a?(Net::HTTPRedirection) && ignore_302s
            raise InvalidResponseError.new("Did not get a valid response, #{response.inspect}")
          end
        end
      end

      # convert the fields hash into a param string suitable for a URL request
      def build_form_string(fields)
        return nil if fields.nil?
        tmp = []
        fields.each{|k,v|
          tmp << "#{k.to_s}=#{v.to_s}"
        }
        tmp.join("&")
      end


      # convert the fields hash into a param string suitable for a URL request
      def build_query_string(fields)
        return nil if fields.nil?
        tmp = []
        fields.each{|k,v|
          tmp << "#{k.to_s}=#{CGI::escape(v.to_s)}"
        }
        tmp.join("&")
      end
      
      private
      def setup_http(server_opts={})
        timeout = convert_opt(server_opts[:timeout])
        logger.debug("setup_http: #{server_opts.inspect}")
        http = Net::HTTP.new(server_opts[:host],server_opts[:port])
        if server_opts[:port].to_i == 443
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          # http.timeout = timeout
        end
        http.open_timeout = timeout
        http
      end
      def logger
        @logger ||= RAILS_DEFAULT_LOGGER
      end
      
            
    end

  end
  
    
end