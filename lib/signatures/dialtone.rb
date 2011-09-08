module Signatures
  class Dialtone
    def self.process data
      #
      # Dial tone detection (440hz + 350hz)
      #
      if(data[:fcnt][440] > 1.0 and data[:fcnt][350] > 1.0)
        return 'dialtone'
      end
    end
  end
end