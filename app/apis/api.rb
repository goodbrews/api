require 'app/apis/breweries_api'
require 'app/apis/webhooks_api'

module Goodbrews
  class API < Grape::API
    format :json

    mount BreweriesAPI
    mount WebhooksAPI
  end
end
