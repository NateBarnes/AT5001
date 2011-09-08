module Signatures
  class Fax
    def self.process data
      fax_sum = 0
      [
      	data[:fcnt][1625], data[:fcnt][1660], data[:fcnt][1825], data[:fcnt][2100],
      	data[:fcnt][600],  data[:fcnt][1855], data[:fcnt][1100], data[:fcnt][2250],
      	data[:fcnt][2230], data[:fcnt][2220], data[:fcnt][1800], data[:fcnt][2095],
      	data[:fcnt][2105]
      ].map{|x| fax_sum += [x,1.0].min }
      if(fax_sum >= 2.0)
      	return 'fax'
      end
    end
  end
end