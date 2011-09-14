AudioJob = Struct.new :number
AudioJob.class_eval { @queue = :audio }
$redis = Redis.new
