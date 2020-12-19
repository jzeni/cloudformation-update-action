FROM ruby:2.7.2-alpine3.12


ENV AWS_ACCESS_KEY_ID=AKIATFCXVQDACGZTWPXR
ENV AWS_SECRET_ACCESS_KEY=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
ENV AWS_REGION="us-east-1"
ENV CAPABILITIES="[\"CAPABILITY_NAMED_IAM\"]"
ENV STACK_NAME='test-app'
ENV PARAMETER_OVERRIDES="[{ \"parameter_key\": \"AppImageTag\", \"parameter_value\": \"latest\" }]"
# ENV FOLLOW_STATUS=true
ENV ATTEMPTS_DELAY=5
ENV MAX_ATTEMPTS=20
ENV CANCEL_ON_TIMEOUT=true

RUN gem install aws-sdk-cloudformation -v '~> 1'

WORKDIR /usr/src/cfn-update

COPY . .

ENTRYPOINT ["/usr/src/cfn-update/entrypoint.rb"]
