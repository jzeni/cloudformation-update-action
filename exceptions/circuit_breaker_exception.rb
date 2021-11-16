class CircuitBreakerException < StandardError
  def initialize(errors)
    error_message = errors.reduce('') do |accum, curr|
      "#{accum} \n\n#{curr}"
    end

    super(error_message)
  end
end
