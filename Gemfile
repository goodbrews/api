# A sample Gemfile
source 'https://rubygems.org'

# Infrastructure.
gem 'grape'
gem 'puma'
gem 'rake'
gem 'app'

# Data storage.
gem 'activerecord', '~> 4.0.0', require: 'active_record'
gem 'recommendable', github: 'davidcelis/recommendable'
gem 'pg'

# Email/Notifications.
gem 'mail'

# Utilities.
gem 'bcrypt-ruby', '~> 3.1.2'
gem 'pry', group: [:development, :test]
gem 'log4r'

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'database_cleaner'

  gem 'miniskirt'
  gem 'ffaker'

  gem 'webmock'
  gem 'vcr'

  gem 'coveralls', require: false
end
