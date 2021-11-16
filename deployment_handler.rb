require_relative 'exceptions/timeout_exception'
require_relative 'exceptions/circuit_breaker_exception'

class DeploymentHandler
  def initialize(ecs_client, change_set)
    @ecs_client = ecs_client
    @target_services = target_services(change_set)

    @deployment_ids = {}

    @target_services.each do |service|
      @deployment_ids[service] =
        @ecs_client.deployment_id(service)
    end
  end

  def target_services(change_set)
    service_changes = change_set[:changes].select do |curr_change|
      change = curr_change[:resource_change]

      change[:resource_type] == 'AWS::ECS::Service'
    end

    service_changes.map do |curr_change|
      change = curr_change[:resource_change]
      change[:physical_resource_id].split('/').last
    end
  end

  def look_for_rollback!
    errors = []
    @target_services.each do |service|
      prev_deployment_id = @deployment_ids[service]
      curr_deployment_id = @ecs_client.deployment_id(service)

      next if prev_deployment_id != curr_deployment_id

      errors.push(
        "Deployment of service #{service} was rolled back by Circuit Breaker"
      )
    end

    raise CircuitBreakerException.new errors unless errors.empty?
  end

  def look_for_errors!
    tasks_errors = []

    @target_services.each do |service|
      deployment_id = @ecs_client.deployment_id(service)
      task_error = deployment_errors(deployment_id)
      next unless task_error

      tasks_errors.push({ error_msg: task_error, service_name: service })
    end

    raise TimeoutException.new tasks_errors
  end

  def deployment_errors(deployment_id)
    failed_tasks_arns = @ecs_client.list_tasks(
      deployment_id,
      EcsClient::TASKS_STATUSES[:STOPPED]
    )

    return nil if failed_tasks_arns.empty?

    tasks_desc = @ecs_client.describe_tasks(failed_tasks_arns)

    tasks_desc[:tasks][0][:stopped_reason]
  end
end
