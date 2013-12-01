require 'app/models/concerns/socialable'
require 'app/models/concerns/sluggable'
require 'app/models/brewery'
require 'app/models/event'
require 'app/models/ingredient'
require 'app/models/style'

class Beer < ActiveRecord::Base
  include Socialable
  include Sluggable

  has_and_belongs_to_many :breweries
  has_and_belongs_to_many :events
  has_and_belongs_to_many :ingredients
  belongs_to :style

  before_destroy { [breweries, events, ingredients].each(&:clear) }
end
