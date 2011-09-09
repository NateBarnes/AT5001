require 'redis'
require 'proc_audio'

class AudioJob
  @queue = :audio
  @redis = Redis.new
  
  def self.perform call_id
    p = ProcAudio.new "data/call_#{call_id}.wav"
    begin
      p.process
    rescue StandardError => e
      puts "FAILURE"
      puts e.backtrace
    end
  end
end
