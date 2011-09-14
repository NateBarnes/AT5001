class AudioController < ApplicationController
  def create
    puts "PARAMS: #{params["filename"]}"
    @opts = YAML::load $redis.get params[:id]
    if @opts.nil?
    else
      save params["filename"], params[:id]
      @opts[:status] = "Audio Saved"
      $redis.set params[:id], @opts.to_yaml
      Resque.enqueue AudioJob, params[:id]
    end
  end

private
  def save audio, id
    name = "call_#{id}.wav"
    directory = "../data"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(audio.read) }
  end

end
