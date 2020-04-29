FROM ruby:2.6.5
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN gem install bundler
ADD Gemfile* /app/
WORKDIR /app
RUN bundle install --without=development test
ENV RAILS_ENV production
ADD . .
RUN rails assets:precompile
