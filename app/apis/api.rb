require 'app/apis/webhooks_api'

module Goodbrews
  class API < Grape::API
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    format :json

    mount WebhooksAPI
  end
end
