# Load the Grape application.
require File.expand_path('../config/application', __FILE__)
require 'app/apis/api'

use ActiveRecord::ConnectionAdapters::ConnectionManagement

if Crepe.env.development?
  require 'new_relic/rack/developer_mode'
  use NewRelic::Rack::DeveloperMode
end

NewRelic::Agent.manual_start

run Goodbrews::API
