methods_for :dialplan do
  def battleplan
    Battleplan.new(self).start
  end
end

class Battleplan

  def initialize(call)
    @call = call
    @redis = Redis.new
  end

  def start
    num = JSON.parse(@call.tropo_headers)["tropo_tag"]
    res = @call.execute "startcallrecording", { 'uri' => "http://li215-167.members.linode.com:3000/audio/#{num}", :method => "POST",
                                          :format => "audio/wav" }.to_json
    @call.play "This is a test of the A T 5001 system. Sorry for the inconvience."
    sleep 10
    @call.hangup
    @opts = YAML::load @redis.get num
    @opts[:status] = "Call Recieved"
    @redis.set num, @opts.to_yaml
  end
end
