module Signatures
  class Voicemail
    def self.process data
      # Look for voice mail by detecting the 1000hz BEEP
      # If the call length was too short to catch the beep,
      # this signature can fail. For non-US numbers, the beep
      # is often a different frequency entirely.
      if(data[:fcnt][1000] >= 1.0)
      	return 'voicemail'
      end

      # Look for voicemail by detecting a peak frequency of
      # 1000hz. Not as accurate, but thats why this is in
      # the fallback script.
      if(data[:maxf] > 995 and data[:maxf] < 1005)
      	return 'voicemail'
      end
    end
  end
end