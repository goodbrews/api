# Measure test coverage
require 'coveralls'
Coveralls.wear!

ENV['GRAPE_ENV'] ||= 'test'
require File.expand_path("../../config/application", __FILE__)

# Require support files, including Factories
Dir[Grape.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

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

  def app
    let(:app) { Goodbrews::API }
  end
end