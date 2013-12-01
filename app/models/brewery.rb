require 'app/models/concerns/socialable'
require 'app/models/concerns/sluggable'
require 'app/models/beer'
require 'app/models/event'
require 'app/models/guild'
require 'app/models/location'

class Brewery < ActiveRecord::Base
  include Socialable
  include Sluggable

  has_and_belongs_to_many :beers
  has_and_belongs_to_many :events
  has_and_belongs_to_many :guilds
  has_many :locations, dependent: :destroy

  before_destroy { [beers, events, guilds].each(&:clear) }
end
