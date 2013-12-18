require 'app/helpers/pagination_helper'
require 'app/apis/breweries_api'
require 'app/apis/webhooks_api'

module Goodbrews
  class API < BaseAPI
    mount BreweriesAPI
    mount WebhooksAPI
  end
end
