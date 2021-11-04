class TimeoutException < StandardError
  def initialize(reason)
    error_message = "Time exceeded. Reason: #{reason}"
    super(error_message)
  end
end
