require 'app/models/beer'
require 'app/models/event'

class BeerEvent < ActiveRecord::Base
  belongs_to :beer,  counter_cache: 'events_count'
  belongs_to :event, counter_cache: 'beers_count'
end
