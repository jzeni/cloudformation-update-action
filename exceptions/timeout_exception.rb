class TimeoutException < StandardError
  def initialize(errors)
    error_message = ''

    if errors.empty?
      error_message = 'Time exceeded while updating service. No errors found in tasks. Try increasing [attempts_delay] or [max_attempts] parameters'
    else
      error_message = errors.reduce('') do |accum, curr|
        "#{accum} \n\nTime exceeded while updating service: #{curr[:service_name]}. Reason: #{curr[:error_msg]}"
      end
    end

    super(error_message)
  end
end
