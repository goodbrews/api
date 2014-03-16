# A sample Gemfile
source 'https://rubygems.org'

# Infrastructure.
gem 'crepe', github: 'crepe/crepe'
gem 'puma'
gem 'rake'

# Background processing.
gem 'sidekiq'
gem 'sidekiq-unique-jobs'
gem 'sinatra', '1.3.0', require: nil, group: :production

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
gem 'dotenv'

# Monitoring.
gem 'new_relic-crepe', github: 'crepe/new_relic-crepe'

gem 'foreman', group: :development

group :deployment do
  gem 'capistrano', '~> 3.1.0'
  gem 'capistrano-chruby', '~> 0.1.1'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano3-puma', '~> 0.2.2'
  gem 'capistrano-rails', '~> 1.1'
end

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
