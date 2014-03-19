# Load the Crepe application.
require File.expand_path('../config/application', __FILE__)
require 'new_relic/rack/agent_hooks'
require 'new_relic/rack/error_collector'
require 'app/apis/api'

use NewRelic::Rack::AgentHooks
use NewRelic::Rack::ErrorCollector

use ActiveRecord::ConnectionAdapters::ConnectionManagement

if Crepe.env.development?
  require 'new_relic/rack/developer_mode'
  use NewRelic::Rack::DeveloperMode
end

NewRelic::Agent.manual_start

run Goodbrews::API
