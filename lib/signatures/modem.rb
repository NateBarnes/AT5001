module Signatures
  class Modem
    def self.process data
      if( (data[:fcnt][2100] > 1.0 or data[:fcnt][2230] > 1.0) and data[:fcnt][2250] > 0.5)
      	return 'modem'
      end

      #
      # Look for modems by detecting a peak frequency of 2250hz
      #
      if(data[:fcnt][2100] > 1.0 and (data[:maxf] > 2245.0 and data[:maxf] < 2255.0))
      	return 'modem'
      end

      #
      # Look for modems by detecting a peak frequency of 3000hz
      #
      if(data[:fcnt][2100] > 1.0 and (data[:maxf] > 2995.0 and data[:maxf] < 3005.0))
      	return 'modem'
      end
    end
  end
end