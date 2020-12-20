FROM ruby:2.7.2-alpine3.12


# ENV AWS_ACCESS_KEY_ID
# ENV AWS_SECRET_ACCESS_KEY
# ENV AWS_REGION
# ENV CAPABILITIES
# ENV STACK_NAME
# ENV PARAMETER_OVERRIDES
# ENV FOLLOW_STATUS=true
# ENV ATTEMPTS_DELAY=5
# ENV MAX_ATTEMPTS=20
# ENV CANCEL_ON_TIMEOUT=true

RUN gem install aws-sdk-cloudformation -v '~> 1'

WORKDIR /usr/src/cfn-update

COPY . .

ENTRYPOINT ["/usr/src/cfn-update/entrypoint.rb"]
