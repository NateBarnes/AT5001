class AudioJob
  @queue = :audio
  
  def self.perform filename
    puts "YAR"
  end
end

AudioJob.perform ARGV.first unless ARGV.empty?