#!/usr/bin/env ruby

require 'aws-sdk-cloudformation'
require_relative 'cfn_update'

opts = {
  access_key_id:        ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key:    ENV['AWS_SECRET_ACCESS_KEY'],
  aws_region:           ENV['AWS_REGION'],
  stack_name:           ENV['STACK_NAME'],
  capabilities:         JSON(ENV['CAPABILITIES'] || "[]"),
  parameter_overrides:  JSON(ENV['PARAMETER_OVERRIDES'] || "[]"),
  follow_status:        ENV['FOLLOW_STATUS'] == 'true',
  attempts_delay:       (ENV['ATTEMPTS_DELAY'] || 5).to_i,
  max_attempts:         (ENV['MAX_ATTEMPTS'] || 20).to_i,
  cancel_on_timeout:    ENV['CANCEL_ON_TIMEOUT'] == 'true'
}

begin
  CfnUpdate.run(opts)
  puts "Stack updated successfully"
rescue StandardError => error
  puts "Error: #{error.message}"
  exit 1
end
