#!/usr/bin/env ruby

require 'aws-sdk-ecs'
require 'aws-sdk-cloudformation'
require_relative 'cfn_update'
require_relative 'exceptions/timeout_exception'

opts = {
  access_key_id:        ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key:    ENV['AWS_SECRET_ACCESS_KEY'],
  aws_region:           ENV['AWS_REGION'],
  stack_name:           ENV['STACK_NAME'],
  cluster_name:         ENV['CLUSTER_NAME'],
  service_name:         ENV['SERVICE_NAME'],
  capabilities:         JSON(ENV['CAPABILITIES'] || "[]"),
  parameter_overrides:  JSON(ENV['PARAMETER_OVERRIDES'] || "[]"),
  follow_status:        ENV['FOLLOW_STATUS'] == 'true',
  attempts_delay:       (ENV['ATTEMPTS_DELAY'] || 5).to_i,
  max_attempts:         (ENV['MAX_ATTEMPTS'] || 20).to_i,
  cancel_on_timeout:    ENV['CANCEL_ON_TIMEOUT'] == 'true'
}

begin
  cfn_client = CfnUpdate.new(opts)
  cfn_client.run
  puts 'Stack updated successfully'
rescue TimeoutException => e
  cfn_client.cancel_update if opts[:cancel_on_timeout]
  puts "Error: #{e.message}"
  exit 1
rescue StandardError => e
  puts "Error: #{e.message}"
  exit 1
end
