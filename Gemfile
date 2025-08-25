source "https://rubygems.org"

gem 'twilio-ruby'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.2"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server
gem "puma", ">= 5.0"

# Use Redis adapter to run Action Cable in production
gem "redis"

# Use Kredis to get higher-level data types in Redis
# gem "kredis"

# Use Active Model has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS)
gem "rack-cors"

# Active Model Serializers (available in production)
gem 'active_model_serializers', '~> 0.10.0'

# Devise authentication (needed in production)
gem "devise"
gem "devise-jwt"

# AWS S3 support for Active Storage
gem "aws-sdk-s3", require: false

group :development, :test do
  # Debugging
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Security static analysis
  gem "brakeman", require: false

  # Ruby styling
  gem "rubocop-rails-omakase", require: false
end
