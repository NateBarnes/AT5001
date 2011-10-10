class AudioController < ApplicationController
  def show
    filename = '#{params[:id]}.wav'
    extname = File.extname(filename)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(extname)
    content_type = mime_type.to_s unless mime_type.nil?

    # 1
    #headers['Content-Type'] = content_type
    #render :file => filename

    # 2
    p "CONTENT TYPE IS #{content_type}"
    render :file => filename, :content_type => "audio/wav"
    #send_file(File.join(Rails.root, "public/audio", "#{params[:id]}.wav"))
  end
  
  def create
    puts "PARAMS: #{params["filename"]}"
    @opts = YAML::load $redis.get params[:id]
    if @opts.nil?
    else
      save params["filename"], params[:id]
      @opts[:status] = "Audio Saved"
      $redis.set params[:id], @opts.to_yaml
      Call.find_by_public_id(params[:id]).status = "Processing Audio"
      Resque.enqueue AudioJob, params[:id]
    end
  end

private
  def save audio, id
    name = "call_#{id}.wav"
    directory = "public/audio/"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(audio.read) }
  end

end
