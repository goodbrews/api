# Load the Grape application.
require File.expand_path('../config/application', __FILE__)
require 'app/apis/api'

run Goodbrews::API
