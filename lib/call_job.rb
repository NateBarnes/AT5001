require "net/http"
require "yaml"
require "redis"
require "json"

class CallJob
  @queue = :call
  @token = YAML.load_file("config/at5001_config.yml")["provider"]["token"]
  @redis = Redis.new
  
  def self.perform number
    tries = 0
    begin
      call_num = @redis.incr "calls"
      res = Net::HTTP.post_form(URI.parse('http://api.tropo.com/1.0/sessions'), 
                                          "token" => @token, "destination" => number,
                                          "tropo_tag" => call_num)
    rescue SocketError => se
      if tries < 3
        tries += 1
        retry
      else
        puts se
      end
    end
  end
  
end
