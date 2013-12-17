require 'active_support/dependencies'

# Load environment-specific configuration
pathname = Crepe.root.join('config', 'environment', Crepe.env)
require_dependency pathname.to_s

# Initialize ActiveSupport's default time zone
Time.zone = Goodbrews::Application.time_zone
