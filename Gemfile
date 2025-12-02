source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.3"
# Use mysql as the database for Active Record (development/test)
gem "mysql2", "~> 0.5"
# Use postgresql as the database for Active Record (production)
gem "pg", ">= 1.5", group: :production
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  # RSpec for testing
  gem "rspec-rails", "~> 6.0"
end
