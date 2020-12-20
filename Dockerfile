FROM ruby:2.7.2-alpine3.12

RUN gem install aws-sdk-cloudformation -v '~> 1'

WORKDIR /usr/src/cfn-update

COPY . .

ENTRYPOINT ["/usr/src/cfn-update/entrypoint.rb"]
