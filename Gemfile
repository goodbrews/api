# A sample Gemfile
source 'https://rubygems.org'

# Infrastructure.
gem 'crepe', github: 'stephencelis/crepe'
gem 'puma'
gem 'rake'

# Background processing.
gem 'sidekiq'
gem 'sidekiq-unique-jobs'

# Data storage.
gem 'activerecord', '~> 4.0.0', require: 'active_record'
gem 'recommendable', github: 'davidcelis/recommendable'
gem 'pg'

# Presentation.
gem 'jsonite', github: 'barrelage/jsonite'
gem 'kaminari', require: false

# Email/Notifications.
gem 'mail', '~> 2.5.4'

# Utilities.
gem 'bcrypt-ruby', '~> 3.1.2'

# Monitoring.
gem 'new_relic-crepe', github: 'davidcelis/new_relic-crepe'

gem 'foreman', group: :development
gem 'capistrano', '~> 3.1.0'

group :development, :test do
  gem 'pry'

  # Miniskirt and FFaker are also used for seed data.
  gem 'miniskirt', require: false
  gem 'ffaker', require: false
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'database_cleaner'

  gem 'webmock'
  gem 'vcr'

  gem 'coveralls', require: false
end
