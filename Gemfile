source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails-api'
gem 'rails', '4.0.0.rc1'
gem 'api-versions', github: 'erichmenge/api-versions'

gem 'puma', '~> 2.0.0'
gem 'pg'

gem 'bcrypt-ruby', '~> 3.0.0'
gem 'active_model_serializers', '~> 0.7.0'

gem 'sidekiq', '~> 2.12.0'
gem 'sidekiq-unique-jobs', '~> 2.6.0'

gem 'recommendable'

# Use Capistrano for deployment
gem 'capistrano', group: :development

# Gems not necessary for production
group :development, :test do
  gem 'minitest-rails'
  gem 'miniskirt'
  gem 'temping'
  gem 'ffaker'
  gem 'mocha', require: false
  gem 'coveralls', require: false

  gem 'pry-rails'
  gem 'pry-coolline'
  gem 'better_errors'
end

gem 'webmock', group: :test
