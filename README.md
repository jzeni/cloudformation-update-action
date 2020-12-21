# CloudFormation stack update

A lightweight action to update a CloudFormation stack **specifying only changing parameters** and **keeping track of the result**.

This action will:
- read the current stack and use the current parameter values except the ones given to override.
- (optional) wait for the stack update to finish and exit with the same status
- (optional) rollback or cancel the update on timeout automatically

## Usage

```
...
steps:
  - uses: jzeni/cloudformation-update-action@master
    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      AWS_REGION: us-east-1
      CAPABILITIES: '["CAPABILITY_NAMED_IAM"]'
      STACK_NAME: test-app
      PARAMETER_OVERRIDES: '[{ "parameter_key": "AppImageTag", "parameter_value": "${{ github.event.inputs.image_tag }}" }]'
      FOLLOW_STATUS: true
      ATTEMPTS_DELAY: 5
      MAX_ATTEMPTS: 20
      CANCEL_ON_TIMEOUT: true
```

## Environment variables

- `AWS_ACCESS_KEY_ID`: [String] AWS access key. Use a secret.
- `AWS_SECRET_ACCESS_KEY`: [String] AWS secret access key. Use a secret.
- `AWS_REGION`: [String] AWS region
- `CAPABILITIES`: [JSON] required AWS capabilities _(optional)_
- `STACK_NAME`: [String] the name of the stack to be updated
- `PARAMETER_OVERRIDES`: [JSON] stack parameters to override. Specify only the ones that needs to be changed.
- `FOLLOW_STATUS`: [Boolean] wait until stack update finishes and return the status. Default: `false`. _(optional)_
- `ATTEMPTS_DELAY`: [Integer] seconds between each status. _(optional)_
- `MAX_ATTEMPTS`: [Integer] polling atempts limit. _(optional)_
- `CANCEL_ON_TIMEOUT`: [Boolean] cancel update when a timeout occurs. Default: `false`. _(optional)_

Notes:
- If `FOLLOW_STATUS` is `true` the action will exit with a failure status when the update process fails, and succeed when tne update was successful.
- If `CANCEL_ON_TIMEOUT` is `true` the action will cancel the stack update and exit with a failure status.

## Licence

This software is licensed under the MIT license.

## Contributing

- Fork it
- Create your feature branch (`git checkout -b my-new-feature`)
- Commit your changes (`git commit -am 'Add some feature'`)
- Push to the branch (`git push origin my-new-feature`)
- Create new Pull Request
