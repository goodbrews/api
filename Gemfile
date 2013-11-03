# A sample Gemfile
source 'https://rubygems.org'

# Infrastructure.
gem 'grape'
gem 'puma'
gem 'rake'
gem 'app'

# Data storage.
gem 'activerecord', '~> 4.0.0', require: 'active_record'
gem 'pg'

# Utilities.
gem 'bcrypt-ruby', '~> 3.1.2'

group :development, :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'database_cleaner'

  gem 'miniskirt'
  gem 'ffaker'

  gem 'pry'
  gem 'coveralls', require: false
end
