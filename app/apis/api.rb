require 'app/apis/breweries_api'
require 'app/apis/webhooks_api'

module Goodbrews
  class API < Crepe::API
    respond_to :json

    mount BreweriesAPI
    mount WebhooksAPI
  end
end
