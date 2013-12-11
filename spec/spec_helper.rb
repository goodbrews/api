# Measure test coverage.
require 'coveralls'
Coveralls.wear!

ENV['GRAPE_ENV'] ||= 'test'
require File.expand_path("../../config/application", __FILE__)
require 'webmock/rspec'
require 'vcr'

# Require support files, including Factories.
Dir[Grape.root.join('spec/support/**/*.rb')].each { |f| require f }

# Don't be slow, BCrypt. Not here. Not now.
ActiveModel::SecurePassword.min_cost = true

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/vcr_cassettes'
  c.hook_into :webmock
  c.filter_sensitive_data('secret_api_key') { ENV['BREWERY_DB_API_KEY'] }
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DeferredGarbageCollection.start
  end

  config.before(:each) { DatabaseCleaner.start }
  config.after(:each)  { DatabaseCleaner.clean }

  config.before(:all)  { DeferredGarbageCollection.start }
  config.after(:all)   { DeferredGarbageCollection.reconsider }

  config.order = 'random'

  def app() Goodbrews::API end
end
