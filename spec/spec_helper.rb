# Measure test coverage.
require 'coveralls'
Coveralls.wear!

ENV['RACK_ENV'] ||= 'test'
require File.expand_path("../../config/application", __FILE__)
require 'webmock/rspec'
require 'vcr'
require 'mail'

# Disable Sidekiq logging
require 'sidekiq/testing'
Sidekiq::Logging.logger = nil

# Require support files, including Factories.
Dir[Crepe.root.join('spec/support/**/*.rb')].each { |f| require f }

# Don't be slow, BCrypt. Not here. Not now.
ActiveModel::SecurePassword.min_cost = true

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/vcr_cassettes'
  c.hook_into :webmock
  c.filter_sensitive_data('secret_api_key') { ENV['BREWERY_DB_API_KEY'] }
end

NewRelic::Agent.manual_start

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Mail::Matchers

  # Disable the 'should' syntax.
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Clear out the database between every test case and defer garbage
  # collection until it's really needed.
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DeferredGarbageCollection.start
  end

  config.before(:each) do
    DatabaseCleaner.start
    Mail::TestMailer.deliveries.clear
  end

  config.after(:each) do
    DatabaseCleaner.clean
    Recommendable.redis.flushdb
  end

  config.before(:all)  { DeferredGarbageCollection.start }
  config.after(:all)   { DeferredGarbageCollection.reconsider }

  # No ordering issues here.
  config.order = 'random'
end
