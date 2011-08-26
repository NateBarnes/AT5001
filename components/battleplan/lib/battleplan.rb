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
    res = @call.execute "startcallrecording", { 'uri' => "http://li215-167.members.linode.com:3000/audio/12345", :method => "PUT",
                                          :format => "mp3" }.to_json
    sleep 10
    @call.hangup
  end
end
