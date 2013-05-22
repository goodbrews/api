source 'https://rubygems.org'

if defined?(JRUBY_VERSION)
  ruby '1.9.3' # There are still Rails 4 bugs with JRuby in 2.0 mode.
else
  ruby '2.0.0'
end

gem 'rails-api'
gem 'rails', '4.0.0.rc1'
gem 'api-versions', github: 'erichmenge/api-versions'

gem 'puma', '~> 2.0.0'

platforms :ruby do
  gem 'pg'
end

platforms :jruby do
  gem 'activerecord-jdbcpostgresql-adapter', '1.3.0.beta1'
end

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
  gem 'temping', github: 'davidcelis/temping'
  gem 'ffaker'
  gem 'mocha', require: false
  gem 'coveralls', require: false

  gem 'pry-rails'
  gem 'pry-coolline' unless defined?(JRUBY_VERSION)
  gem 'better_errors'
end

gem 'webmock', group: :test
