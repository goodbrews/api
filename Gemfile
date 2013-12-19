# A sample Gemfile
source 'https://rubygems.org'

# Infrastructure.
gem 'crepe', github: 'stephencelis/crepe'
gem 'puma'
gem 'rake'
gem 'app'

# Data storage.
gem 'activerecord', '~> 4.0.0', require: 'active_record'
gem 'recommendable', github: 'davidcelis/recommendable'
gem 'pg'

# Presentation.
gem 'jsonite', github: 'barrelage/jsonite'
gem 'kaminari', require: false

# Background processing.
gem 'sidekiq'
gem 'sidekiq-unique-jobs'

# Email/Notifications.
gem 'mail'

# Utilities.
gem 'bcrypt-ruby', '~> 3.1.2'

# Monitoring.
gem 'newrelic_rpm'

group :development, :test do
  gem 'guard'
  gem 'guard-puma'
  gem 'pry'
end

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
