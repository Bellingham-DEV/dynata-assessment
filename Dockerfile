FROM ruby:3.2-slim
RUN apt-get update -qq && apt-get install -yq --no-install-recommends build-essential
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
EXPOSE 3000
CMD ["bundle", "exec", "ruby", "app.rb"]
