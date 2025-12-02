FROM ruby:3.3.0-alpine

RUN apk add --no-cache \
    build-base \
    mysql-dev \
    mysql-client \
    postgresql-dev \
    tzdata \
    nodejs \
    npm

# Install OpenAPI lint tools
RUN npm install -g @stoplight/spectral-cli@latest @redocly/cli@latest

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN if [ -z "$BUNDLE_WITHOUT" ]; then \
    bundle install; \
    else \
    bundle config set --local without "$BUNDLE_WITHOUT" && \
    bundle install; \
    fi

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
