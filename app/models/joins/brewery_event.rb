require 'app/models/brewery'
require 'app/models/event'

class BreweryEvent < ActiveRecord::Base
  belongs_to :brewery, counter_cache: 'events_count'
  belongs_to :event,   counter_cache: 'breweries_count'
end
