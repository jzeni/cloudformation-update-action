require_relative 'cfn_client'
require_relative 'ecs_client'
require_relative 'deployment_handler'

class CfnUpdate
  SUCCESSFUL_STATUSES = ['UPDATE_COMPLETE', 'UPDATE_COMPLETE_CLEANUP_IN_PROGRESS']

  def initialize(opts)
    @opts = opts
    @deployment_handler = DeploymentHandler.new(ecs_client, describe_change_set)
    validate_opts!
  end

  def run
    update_stack
    stack.reload

    if @opts[:follow_status]
      follow_status

      # Something wrong with the ECS configuration.
      unless SUCCESSFUL_STATUSES.include?(stack.reload.stack_status)
        raise "Update failed, Status: #{stack.stack_status}"
      end

      # Sometimes Circuit Breaker rollbacks the deployment.
      # That can be caused by a failing health check or task, etc.
      @deployment_handler.look_for_rollback!
    end
  end

  def update_stack
    client.update_stack(@opts[:stack_name], parameters_for_update, @opts[:capabilities])
  end

  def describe_change_set
    client.describe_change_set(@opts[:stack_name], parameters_for_update, @opts[:capabilities])
  end

  def follow_status
    opts = { delay: @opts[:attempts_delay], max_attempts: @opts[:max_attempts] }

    stack.wait_until(opts) { |i| i.stack_status != 'UPDATE_IN_PROGRESS' }
  rescue Aws::Waiters::Errors::TooManyAttemptsError
    @deployment_handler.look_for_errors!
  end

  def cancel_update
    client.cancel_update(@opts[:stack_name])
  end

  def parameters_for_update
    current_parameters = stack.parameters

    current_parameter_keys = current_parameters.map do |parameter|
                                parameter[:parameter_key]
                              end

    parameter_overrides_keys = @opts[:parameter_overrides].map do |new_value|
                                  new_value['parameter_key']
                                end

    parameters = current_parameter_keys.map do |key|
                    unless parameter_overrides_keys.include?(key)
                      { parameter_key: key, use_previous_value: true }
                    end
                  end

    parameters.compact!

    @opts[:parameter_overrides].each do |param|
      parameters << { parameter_key: param['parameter_key'], parameter_value: param['parameter_value'] }
    end

    parameters
  end

  def stack
    @stack ||= client.get_stack(@opts[:stack_name])
  end

  def client
    @client ||= CfnClient.new(@opts[:access_key_id], @opts[:secret_access_key], @opts[:aws_region])
  end

  def ecs_client
    @ecs_client ||= EcsClient.new(
      @opts[:access_key_id],
      @opts[:secret_access_key],
      @opts[:aws_region],
      @opts[:cluster_name]
    )
  end

  def validate_opts!
    required_vars = [
      :access_key_id, :secret_access_key,
      :aws_region, :stack_name, :cluster_name
    ]

    missing = []
    required_vars.each do |var|
      missing << var unless @opts[var]
    end

    raise "Variables #{missing.join(',')} are required." if missing.any?

    raise 'At least one parameter must be specified' if @opts[:parameter_overrides].empty?

    if @opts[:cancel_on_timeout] && !@opts[:follow_status]
      raise 'Incompatible CANCEL_ON_TIMEOUT with given FOLLOW_STATUS value'
    end
  end
end
