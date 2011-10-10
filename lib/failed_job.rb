require 'redis'
require 'yaml'
require "active_record"
require "gui/app/models/call.rb"

class FailedJob
  @queue = :failure
  @redis = Redis.new
  @dbconf = { :adapter => "sqlite3", :database => "gui/db/development.sqlite3", :pool => 5, :timeout => 5000 }
  
  def self.perform opts
    YAML::ENGINE.yamler="syck"
    ActiveRecord::Base.establish_connection @dbconf
    
    res = YAML::load @redis.get opts["id"]
    call = Call.find_by_public_id opts["id"]
    call.status = "Call Failure"
    res[:failed_reason] = opts["failed_reason"]
    call.results = res.to_yaml
    call.save
  end
end
