require 'active_support/dependencies'

# Load environment-specific configuration
pathname = Grape.root.join('config', 'environment', Grape.env)
require_dependency pathname.to_s

# Initialize ActiveSupport's default time zone
Time.zone = Goodbrews::Application.time_zone
