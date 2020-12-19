class AwsClient

  def initialize(key, secret_key, region)
    @client = Aws::CloudFormation::Client.new(access_key_id: key,
                                              secret_access_key: secret_key,
                                              region: region)

  end

  def update_stack(stack_name, parameters, capabilities)
    opts = {
      stack_name: stack_name,
      use_previous_template: true,
      parameters: parameters
    }

    opts.merge!(capabilities: capabilities) if capabilities.any?

    @client.update_stack(opts)
  end

  def cancel_update(stack_name)
    @client.cancel_update_stack(stack_name: stack_name)
  end

  def get_stack(stack_name)
    Aws::CloudFormation::Stack.new(stack_name, client: @client)
  end

end
