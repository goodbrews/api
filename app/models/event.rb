require 'app/models/concerns/socialable'

require 'app/models/joins/beer_event'
require 'app/models/joins/brewery_event'

class Event < ActiveRecord::Base
  include Socialable

  has_many :beer_events, dependent: :destroy
  has_many :beers, through: :beer_events

  has_many :brewery_events, dependent: :destroy
  has_many :breweries, through: :brewery_events
end
