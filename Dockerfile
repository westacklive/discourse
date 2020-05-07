FROM ruby:2.6.5
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs gcc libxslt-dev libxml2-dev zlib1g-dev libpq-dev imagemagick optipng pngquant jhead jpegoptim gifsicle
RUN gem install bundler
ADD Gemfile* /app/
WORKDIR /app
RUN bundle install --without=development test
ENV RAILS_ENV production
ADD . .
RUN bundle exec rails assets:precompile
RUN mkdir -p /app/tmp/sockets
RUN mkdir -p /app/tmp/pids
# RUN bundle exec rake db:migrate
# ENTRYPOINT bundle exec puma -C config/puma.rb -e production
# bundle exec sidekiq -C config/sidekiq.yml -e production
