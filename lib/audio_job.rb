require 'redis'
require 'yaml'
require 'proc_audio'

class AudioJob
  attr_accessor :opts
  @queue = :audio
  @redis = Redis.new
  
  def self.perform call_id
    @opts = YAML::load @redis.get call_id
    p = ProcAudio.new "gui/public/audio/call_#{call_id}.wav"
    begin
      p.process
      @opts[:status] = "Completed"
      @redis.set call_id, @opts.to_yaml
    rescue Exception => e
      puts "FAILURE"
      puts e.backtrace
    end
  end
end
