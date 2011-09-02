class ProcAudio
  attr_accessor :channels, :header, :file, :line_type, :sample_count
  CHUNK_IDS = {:header       => "RIFF",
                 :format       => "fmt ",
                 :data         => "data",
                 :fact         => "fact",
                 :silence      => "slnt",
                 :cue          => "cue ",
                 :playlist     => "plst",
                 :list         => "list",
                 :label        => "labl",
                 :labeled_text => "ltxt",
                 :note         => "note",
                 :sample       => "smpl",
                 :instrument   => "inst" }
  PACK_CODES = {8 => "C*", 16 => "s*", 32 => "V*"}
  
  def initialize path
    @channels = []
    @file = File.open path
    read_header
    (@header[:channels]).times do |c|
      c += 1
      system "sox #{path} -s #{c}.wav remix #{c}"
      system "sox #{c}.wav -s #{c}.raw"
      system "rm -f #{c}.wav"
      @channels << "#{c}.raw"
    end
  end
  
  def process
    
  end
  
  def cleanup
    @channels.each do |c|
      puts "killing #{c}"
      system "rm -f #{c}"
    end
    @file.close
  end
  
private
  def read_header
    @header = {}

    # Read RIFF header
    riff_header = @file.sysread(12).unpack("a4Va4")
    @header[:chunk_id] = riff_header[0]
    @header[:chunk_size] = riff_header[1]
    @header[:format] = riff_header[2]

    # Read format subchunk
    @header[:sub_chunk1_id], @header[:sub_chunk1_size] = read_to_chunk(CHUNK_IDS[:format])
    format_subchunk_str = @file.sysread(@header[:sub_chunk1_size])
    format_subchunk = format_subchunk_str.unpack("vvVVvv")  # Any extra parameters are ignored
    @header[:audio_format] = format_subchunk[0]
    @header[:channels] = format_subchunk[1]
    @header[:sample_rate] = format_subchunk[2]
    @header[:byte_rate] = format_subchunk[3]
    @header[:block_align] = format_subchunk[4]
    @header[:bits_per_sample] = format_subchunk[5]

    # Read data subchunk
    @header[:sub_chunk2_id], @header[:sub_chunk2_size] = read_to_chunk(CHUNK_IDS[:data])

    @sample_count = @header[:sub_chunk2_size] / @header[:block_align]
  end
  
  def read_to_chunk(expected_chunk_id)
    chunk_id = @file.sysread(4)
    chunk_size = @file.sysread(4).unpack("V")[0]

    while chunk_id != expected_chunk_id
      # Skip chunk
      file.sysread(chunk_size)

      chunk_id = @file.sysread(4)
      chunk_size = @file.sysread(4).unpack("V")[0]
    end

    return chunk_id, chunk_size
  end
  
  def format 
    
  end
end