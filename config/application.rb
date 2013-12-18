require File.expand_path('../boot', __FILE__)
require 'crepe'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Crepe.env)
include Log4r

$:.unshift Crepe.root
$:.unshift Crepe.root.join('lib')

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
