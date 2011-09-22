require "digest"

class Call < ActiveRecord::Base
  def images
    [ "call_#{public_id}_1_big_dots.png",
      "call_#{public_id}_1_big_freq.png",
      "call_#{public_id}_1_big.png",
      "call_#{public_id}_1_sig_freq.png",
      "call_#{public_id}_1_sig.png",
      "call_#{public_id}_2_big_dots.png",
      "call_#{public_id}_2_big_freq.png",
      "call_#{public_id}_2_big.png",
      "call_#{public_id}_2_sig_freq.png",
      "call_#{public_id}_2_sig.png" ]
  end
  
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
      unique_id = Digest::MD5.hexdigest Time.now.to_i.to_s + num
      Call.create! :destination => num, :public_id => unique_id, :status => "Active"
      Resque.enqueue(CallJob, num, unique_id)
    end
  end
end
