require "ruby-kissfft/kissfft"
require "raw"
require "signatures"
require "tempfile"

class ProcAudio
  attr_accessor :channels, :data, :header, :file, :oname, :processors, :results, :sample_count
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
    @channels, @data, @results = [], [], []
    @header = {}
    
    @file = File.open path
    @oname = File.basename path, ".wav"
    read_header
    (@header[:channels]).times do |c|
      c += 1
      system "sox #{path} -s #{c}.wav remix #{c}"
      system "sox #{c}.wav -s #{c}.raw"
      system "rm -f #{c}.wav"
      @channels << "#{c}.raw"
    end
  end
  
  def process opts={}
    if opts[:channel].nil?
      @channels.each do |chan|
        process_audio chan
      end
    else
      process_audio @channels[opts[:channel]-1]
    end
    cleanup
  end
  
  def process_audio input
    bname = File.expand_path(File.dirname(input))
		num   = File.basename(input, ".raw")
		res   = {}

		#
		# Create the signature database
		#
		raw  = Raw.from_file(input)
		fft  = KissFFT.fftr(8192, 8000, 1, raw.samples)

		freq = raw.to_freq_sig_txt()

		# Save the signature data
		res[:fprint] = freq

		#
		# Create a raw decompressed file
		#

		# Decompress the audio file
		rawfile = Tempfile.new("rawfile")
		datfile = Tempfile.new("datfile")

		# Data files for audio processing and signal graph
		cnt = 0
		rawfile.write(raw.samples.pack('v*'))
		datfile.write(raw.samples.map{|val| cnt +=1; "#{cnt/8000.0} #{val}"}.join("\n"))
		rawfile.flush
		datfile.flush

		# Data files for spectrum plotting
		frefile = Tempfile.new("frefile")

		# Calculate the peak frequencies for the sample
		maxf = 0
		maxp = 0
		tones = {}
		fft.each do |x|
			rank = x.sort{|a,b| a[1].to_i <=> b[1].to_i }.reverse
			rank[0..10].each do |t|
				f = t[0].round
				p = t[1].round
				next if f == 0
				next if p < 1
				tones[ f ] ||= []
				tones[ f ] << t
				if(t[1] > maxp)
					maxf = t[0]
					maxp = t[1]
				end
			end
		end

		# Save the peak frequency
		res[:peak_freq] = maxf

		# Calculate average frequency and peaks over time
		avg = {}
		pks = []
		pkz = []
		fft.each do |slot|
			pks << slot.sort{|a,b| a[1] <=> b[1] }.reverse[0]
			pkz << slot.sort{|a,b| a[1] <=> b[1] }.reverse[0..9]
			slot.each do |f|
				avg[ f[0] ] ||= 0
				avg[ f[0] ] +=  f[1]
			end
		end

		# Save the peak frequencies over time
		res[:peak_freq_data] = pks.map{|f| "#{f[0]}-#{f[1]}" }.join(" ")

		# Generate the frequency file
		avg.keys.sort.each do |k|
			avg[k] = avg[k] / fft.length
			frefile.write("#{k} #{avg[k]}\n")
		end
		frefile.flush

		# Count significant frequencies across the sample
		fcnt = {}
		0.step(4000, 5) {|f| fcnt[f] = 0 }
		pkz.each do |fb|
			fb.each do |f|
				fdx = ((f[0] / 5.0).round * 5.0).to_i
				fcnt[fdx]  += 0.1
			end
		end
		
		@data << { :raw  => raw, :freq => freq, :fcnt => fcnt, :fft  => fft,
		          :pks  => pks, :pkz  => pkz, :maxf => maxf, :maxp => maxp }
		
		sigs = Signatures::Base.new @data.last
		res[:line_type] = sigs.process
    
    # Plot samples to a graph
    plotter = Tempfile.new("gnuplot")
    
    current_dir = `pwd`.gsub "\n", ""
    
    plotter.puts("set ylabel \"Signal\"")
    plotter.puts("set xlabel \"Seconds\"")
    plotter.puts("set terminal png medium size 640,480 transparent")
    plotter.puts("set output \"#{current_dir}/gui/public/images/call/#{oname}_#{num}_big.png\"")
    plotter.puts("plot \"#{datfile.path}\" using 1:2 title \"#{num}\" with lines")
    plotter.puts("set output \"#{current_dir}/gui/public/images/call/#{oname}_#{num}_big_dots.png\"")
    plotter.puts("plot \"#{datfile.path}\" using 1:2 title \"#{num}\" with dots")
    
    plotter.puts("set terminal png medium size 640,480 transparent")
    plotter.puts("set ylabel \"Power\"")
    plotter.puts("set xlabel \"Frequency\"")
    plotter.puts("set output \"#{current_dir}/gui/public/images/call/#{oname}_#{num}_big_freq.png\"")
    plotter.puts("plot \"#{frefile.path}\" using 1:2 title \"#{num} - Peak #{maxf.round}hz\" with lines")
    
    plotter.puts("set ylabel \"Signal\"")
    plotter.puts("set xlabel \"Seconds\"")
    plotter.puts("set terminal png small size 160,120 transparent")
    plotter.puts("set format x ''")
    plotter.puts("set format y ''")
    plotter.puts("set output \"#{current_dir}/gui/public/images/call/#{oname}_#{num}_sig.png\"")
    plotter.puts("plot \"#{datfile.path}\" using 1:2 notitle with lines")
    
    plotter.puts("set ylabel \"Power\"")
    plotter.puts("set xlabel \"Frequency\"")
    plotter.puts("set terminal png small size 160,120 transparent")
    plotter.puts("set format x ''")
    plotter.puts("set format y ''")
    plotter.puts("set output \"#{current_dir}/gui/public/images/call/#{oname}_#{num}_sig_freq.png\"")
    plotter.puts("plot \"#{frefile.path}\" using 1:2 notitle with lines")
    plotter.flush
    
    puts `gnuplot #{plotter.path}&`
    File.unlink(plotter.path)
    File.unlink(datfile.path)
    File.unlink(frefile.path)
    plotter.close
    datfile.close
    frefile.path
    
    @results << res
  end
  
  def cleanup
    @channels.each do |c|
      system "rm -f #{c}"
    end
    @file.close
    
    true
  end
  
private
  def read_header
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