# Measure test coverage
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails'
require 'webmock/minitest'

# Use Mocha for mocking/stubbing
require 'mocha/setup'

# Uncomment for awesome colorful output
require 'minitest/pride'

# Require miniskirt factories
Dir[Rails.root.join('test', 'factories', '**', '*.rb')].each { |f| require f }

# Allow RSpec-style context blocks
class ActiveSupport::TestCase
  class << self
    alias :context :describe
  end
end

# Allow POST requests with bodies
class ActionController::TestCase
  def raw_post(action, params, body)
    @request.env['RAW_POST_DATA'] = body
    response = post(action, params)
    @request.env.delete('RAW_POST_DATA')
    response
  end
end
