FROM ruby:3.3.0-alpine

RUN apk add --no-cache \
    build-base \
    mysql-dev \
    mysql-client \
    tzdata \
    nodejs \
    npm

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
