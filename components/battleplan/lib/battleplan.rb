methods_for :dialplan do
  def battleplan
    Battleplan.new(self).start
  end
end

class Battleplan

  def initialize(call)
    @call = call
  end

  def start
    num = JSON.parse(@call.tropo_headers)["tropo_tag"]
    res = @call.execute "startcallrecording", { 'uri' => "http://li215-167.members.linode.com:3000/audio/#{num}", :method => "POST",
                                          :format => "wav" }.to_json
    @call.play "This is a test of the A T 5001 system. Sorry for the inconvience."
    sleep 10
    @call.hangup
  end
end
