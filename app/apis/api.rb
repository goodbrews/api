require 'app/helpers/pagination_helper'
require 'app/apis/base_api'
require 'app/apis/beers_api'
require 'app/apis/breweries_api'
require 'app/apis/events_api'
require 'app/apis/guilds_api'
require 'app/apis/ingredients_api'
require 'app/apis/webhooks_api'

module Goodbrews
  class API < BaseAPI
    get do
      {
        _links: {
          beers:       { href: '/beers' },
          breweries:   { href: '/breweries' },
          events:      { href: '/events' },
          guilds:      { href: '/guilds' },
          ingredients: { href: '/ingredients' }
        }
      }
    end

    mount BeersAPI       => :beers
    mount BreweriesAPI   => :breweries
    mount EventsAPI      => :events
    mount GuildsAPI      => :guilds
    mount IngredientsAPI => :ingredients
    mount WebhooksAPI    => '/brewery_db/webhooks/'

    any '*catchall' do
      error! :not_found
    end
  end
end
