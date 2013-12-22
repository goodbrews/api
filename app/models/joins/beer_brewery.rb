require 'app/models/beer'
require 'app/models/brewery'

class BeerBrewery < ActiveRecord::Base
  belongs_to :beer,    counter_cache: 'breweries_count'
  belongs_to :brewery, counter_cache: 'beers_count'
end
