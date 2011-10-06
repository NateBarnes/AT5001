require 'redis'
require 'yaml'
require 'proc_audio'
require "active_record"
require "gui/app/models/call.rb"

class AudioJob
  attr_accessor :opts
  @queue = :audio
  @redis = Redis.new
  @dbconf = { :adapter => "sqlite3", :database => "gui/db/development.sqlite3", :pool => 5, :timeout => 5000 }
  
  def self.perform call_id
    YAML::ENGINE.yamler="syck"
    ActiveRecord::Base.establish_connection @dbconf
    
    @opts = YAML::load @redis.get call_id
    p = ProcAudio.new "gui/public/audio/call_#{call_id}.wav"
    begin
      p.process
      @opts[:status] = "Completed"
      @redis.set call_id, @opts.to_yaml
      
      c = Call.find_by_public_id call_id
      c.status = "Completed"
      c.line_type = p.results[0][:line_type]
      @opts[:audio_results] = p.results[0]
      c.results = @opts.to_yaml
      c.save
    rescue Exception => e
      puts "FAILURE"
      puts e.backtrace
    end
  end
end
