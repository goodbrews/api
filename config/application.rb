require File.expand_path('../boot', __FILE__)

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, ENV['GRAPE_ENV'])
include Log4r

# Require extensions to Grape
require File.join(ENV['GRAPE_ROOT'], 'lib/core_ext/grape')

module Goodbrews
  class Application < Configurable
    config.mail = OpenStruct.new

    # Set Time.zone default to the specified zone and make Active Record
    # auto-convert to this zone.
    config.time_zone = 'UTC'

    config.mail.raise_delivery_errors = true
  end
end

# Load initializers.
Dir['config/initializers/**/*.rb'].each { |f| require f }
