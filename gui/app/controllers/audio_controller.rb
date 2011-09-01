class AudioController < ApplicationController
  def create
    puts "PARAMS: #{params["filename"]}"
    save params["filename"], params[:id]
  end

private
  def save audio, id
    if audio.original_filename.split(".").last == "mp3"
      name = "call_#{id}.mp3"
      directory = "../data"
      path = File.join(directory, name)
      File.open(path, "wb") { |f| f.write(audio.read) }
    end
  end

end
