class ApplicationController < ActionController::Base
  protect_from_forgery
  
  require "redis"
  require "resque"
end
