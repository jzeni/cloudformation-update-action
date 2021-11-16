class EcsClient
  TASKS_STATUSES = {
    STOPPED: 'STOPPED'
  }.freeze

  def initialize(key, secret_key, region, cluster_name)
    @cluster_name = cluster_name
    @client = Aws::ECS::Client.new(
      access_key_id: key,
      secret_access_key: secret_key,
      region: region
    )
  end

  def describe_service(service_name)
    @client.describe_services({ cluster: @cluster_name,
                                services: [service_name] })
  end

  def deployment_id(service_name)
    describe_service(service_name)[:services][0][:deployments][0][:id]
  end

  def list_tasks(deployment_id, desired_status)
    @client.list_tasks({ cluster: @cluster_name,
                         started_by: deployment_id,
                         desired_status: desired_status }).task_arns
  end

  def describe_tasks(task_arns)
    @client.describe_tasks({ cluster: @cluster_name, tasks: task_arns }).to_h
  end
end
