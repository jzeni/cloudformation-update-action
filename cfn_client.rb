class CfnClient
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

  def create_change_set(stack_name, parameters, capabilities)
    @client.create_change_set({ stack_name: stack_name,
                                change_set_name: "ChangeSet#{Time.now.to_i}",
                                parameters: parameters,
                                change_set_type: 'UPDATE',
                                use_previous_template: true,
                                capabilities: capabilities })
  end

  def describe_change_set(stack_name, parameters, capabilities)
    change_set = create_change_set(stack_name, parameters, capabilities)

    change_set_ready = change_set_ready?(change_set[:id])

    unless change_set_ready
      Timeout::timeout(300) do
        while !change_set_ready
          sleep 10
          change_set_ready = change_set_ready?(change_set[:id])
        end
      end
    end

    @client.describe_change_set({ change_set_name: change_set[:id] })
  end

  def change_set_ready?(change_set_id)
    change_set_desc = @client.describe_change_set(
      {
        change_set_name: change_set_id
      }
    )

    change_set_desc[:status] == 'CREATE_COMPLETE'
  end

  def get_stack(stack_name)
    Aws::CloudFormation::Stack.new(stack_name, client: @client)
  end
end
