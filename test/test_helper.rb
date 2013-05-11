ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
require "minitest/pride"

# Require miniskirt factories
Dir[Rails.root.join('test', 'factories', '**', '*.rb')].each { |f| require f }
class ActiveSupport::TestCase
  class << self
    alias :context :describe
  end
end
