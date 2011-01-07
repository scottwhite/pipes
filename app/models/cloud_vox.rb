require 'net_util'
require 'json'
class CloudVox
  SERVER = 'digits.cloudvox.com'
  
  def self.search(number)
    data = NetUtil::Request.send("/#{number}.json",nil,{timeout: 100, host: SERVER, port: 80})
    JSON::parse(data)
  end
  
  
  def self.state_rate_center(number)
    h = self.search(number)
    {formatted_ratecenter: h['formatted_ratecenter'], ratecenter: h['allocation']['ratecenter'], state: h['allocation']['region']} unless h.blank?
  end
end