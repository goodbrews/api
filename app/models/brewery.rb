require 'app/models/concerns/socialable'
require 'app/models/concerns/sluggable'
require 'app/models/joins/beer_brewery'
require 'app/models/joins/brewery_event'
require 'app/models/joins/brewery_guild'

require 'app/models/location'

class Brewery < ActiveRecord::Base
  include Socialable
  include Sluggable

  has_many :beer_breweries, dependent: :destroy
  has_many :beers, through: :beer_breweries

  has_many :brewery_events, dependent: :destroy
  has_many :events, through: :brewery_events

  has_many :brewery_guilds, dependent: :destroy
  has_many :guilds, through: :brewery_guilds

  has_many :locations, dependent: :destroy

  default_scope { includes(:locations, :social_media_accounts) }
end
