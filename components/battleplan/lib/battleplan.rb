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
                                          :format => "mp3" }.to_json
    sleep 10
    @call.hangup
  end
end
