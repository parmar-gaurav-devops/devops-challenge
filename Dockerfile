# Use official Ruby image
FROM ruby:2.5.9

# Install dependencies for Rails and PostgreSQL
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Set the working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock to cache dependencies
COPY Gemfile Gemfile.lock ./

# Install bundler and gems
RUN gem install bundler -v 1.17.3
RUN bundle install

# Copy the entire application
COPY . .

# Precompile assets (optional)
RUN RAILS_ENV=production bundle exec rake assets:precompile

# Expose port for Puma or Webrick
EXPOSE 3000

# Start the Rails app
CMD ["rails", "server", "-b", "0.0.0.0"]

