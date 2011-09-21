class Call < ActiveRecord::Base
  def self.parse_string num
    if num.include? "*"
      (0..9).each { |i| parse_string num.sub("*", i.to_s) }
    elsif num.include? "["
      set = num.slice num.index("[")+1, num.index("]")-num.index("[")-1
      if set.include? "-"
        min, max = set.split("-")
        (Integer(min)..Integer(max)).each { |i| parse_string num.sub( "["+set+"]", i.to_s )}
      elsif set.include? ","
        set.split(",").each { |s| parse_string num.sub( "["+set+"]", s )}
      end
    else
      Resque.enqueue(CallJob, num)
    end
  end
end
