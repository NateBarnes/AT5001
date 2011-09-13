require "net/http"
require "yaml"
require "redis"
require "digest"

class CallJob
  @queue = :call
  @token = YAML.load_file("config/at5001_config.yml")["provider"]["token"]
  @redis = Redis.new
  
  def self.perform number
    tries = 0
    begin
      unique_id = Digest::MD5.hexdigest Time.now.to_i.to_s + number
      res = Net::HTTP.post_form(URI.parse('http://api.tropo.com/1.0/sessions'), 
                                          "token" => @token, "destination" => number,
                                          "tropo_tag" => unique_id)
      @redis.set unique_id, { :initial_result => res, :status => "Initial Call Placed" }.to_yaml
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
