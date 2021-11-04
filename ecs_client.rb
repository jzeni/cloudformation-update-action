class EcsClient
  TASKS_STATUSES = {
    STOPPED: 'STOPPED'
  }.freeze

  def initialize(key, secret_key, region, cluster_name, service_name)
    @cluster_name = cluster_name
    @service_name = service_name
    @client = Aws::ECS::Client.new(
      access_key_id: key,
      secret_access_key: secret_key,
      region: region
    )
  end

  def describe_service
    @client.describe_services({ cluster: @cluster_name,
                                services: [@service_name] })
  end

  def deployment_id
    describe_service[:services][0][:deployments][0][:id]
  end

  def list_tasks(deployment_id, desired_status)
    @client.list_tasks({ cluster: @cluster_name,
                         started_by: deployment_id,
                         desired_status: desired_status }).task_arns
  end

  def describe_tasks(task_arns)
    @client.describe_tasks({ cluster: @cluster_name, tasks: task_arns }).to_h
  end

  def failed_deployment?(deployment_id)
    failed_tasks_arns = list_tasks(deployment_id, TASKS_STATUSES[:STOPPED])

    return false if failed_tasks_arns.empty?

    tasks_desc = describe_tasks(failed_tasks_arns)

    tasks_desc[:tasks][0][:stopped_reason]
  end
end
