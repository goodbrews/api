require 'app/models/brewery'
require 'app/models/guild'

class BreweryGuild < ActiveRecord::Base
  belongs_to :brewery, counter_cache: 'guilds_count'
  belongs_to :guild,   counter_cache: 'breweries_count'
end
