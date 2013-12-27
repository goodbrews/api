require 'app/helpers/pagination_helper'
require 'app/apis/base_api'
require 'app/apis/authorization_api'
require 'app/apis/beers_api'
require 'app/apis/breweries_api'
require 'app/apis/events_api'
require 'app/apis/guilds_api'
require 'app/apis/ingredients_api'
require 'app/apis/styles_api'
require 'app/apis/users_api'
require 'app/apis/webhooks_api'

module Goodbrews
  class API < BaseAPI
    # TODO: Force SSL
    respond_to :json, :html

    get do
      case format
      when :html
        redirect_to 'https://goodbrews.github.com/api'
      when :json
        {
          _links: {
            authorization: { href: '/authorize', method: 'POST' },
            beers:         { href: '/beers' },
            breweries:     { href: '/breweries' },
            events:        { href: '/events' },
            guilds:        { href: '/guilds' },
            ingredients:   { href: '/ingredients' },
            styles:        { href: '/styles' }
          }
        }
      end
    end

    mount AuthorizationAPI
    mount BeersAPI       => :beers
    mount BreweriesAPI   => :breweries
    mount EventsAPI      => :events
    mount GuildsAPI      => :guilds
    mount IngredientsAPI => :ingredients
    mount StylesAPI      => :styles
    mount UsersAPI       => :users
    mount WebhooksAPI    => '/brewery_db/webhooks/'

    any '*catchall' do
      error! :not_found
    end
  end
end
