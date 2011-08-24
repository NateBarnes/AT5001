require 'resque'

class QueueCalls
  def self.parse_string num
    if num.include? "*"
      (0..9).each { |i| parse_string num.sub("*", i.to_s) }
    else
      puts num
    end
  end
end

QueueCalls.parse_string ARGV[0].dup