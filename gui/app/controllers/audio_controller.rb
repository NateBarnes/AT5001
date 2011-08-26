class AudioController < ApplicationController
  def create
    puts "PARAMS: #{params["filename"]}"
    save params["filename"]
  end

private
  def save audio
    name = audio.original_filename
    directory = "../data"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(audio.read) }
  end

end
