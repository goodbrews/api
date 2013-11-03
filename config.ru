# Load the Grape application.
require File.expand_path('../config/application', __FILE__)
require Grape.root.join('app', 'apis', 'api')

run Goodbrews::API
