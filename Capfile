# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

# Includes tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/seuros/capistrano-puma
#
require 'capistrano/chruby'
require 'capistrano/bundler'
require 'capistrano/puma'
require 'capistrano/rails/migrations'
require 'sidekiq/capistrano'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
