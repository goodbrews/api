require File.expand_path('../boot', __FILE__)
require 'active_support/dependencies'
require 'crepe'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Crepe.env)

# Load ENV variables
Dotenv.load

$:.unshift Crepe.root
$:.unshift Crepe.root.join('lib')

# Initialize ActiveSupport's default time zone.
Time.zone = 'UTC'

# Silence I18n warnings.
I18n.config.enforce_available_locales = true

# Load environment-specific configuration.
pathname = Crepe.root.join('config', 'environment', Crepe.env)
require_dependency pathname.to_s

# Load initializers.
Dir['config/initializers/**/*.rb'].each { |f| require f }

module Goodbrews
  class Application
    class << self
      def load_tasks
        require 'rake'

        Dir['lib/tasks/**/*.rake'].sort.each { |tasks| load tasks }
      end

      def load_seed
        load 'db/seeds.rb'
      end
    end
  end
end
