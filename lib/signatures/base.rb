module Signatures
  class Base
    attr_accessor :data, :processors
    
    def initialize data
      @processors = [Signatures::Fax, Signatures::Modem, Signatures::Dialtone, Signatures::Voicemail, Signatures::Voice]
      @data = data
      
      @data[:scnt] = 0
      @data[:ecnt] = 0
    end
    
    def process
      line_type = nil
      @processors.each do |proc|
        line_type = proc.process @data
        break unless line_type.nil?
      end
      
      line_type.nil? ? 'unknown' : line_type
    end
  end
end