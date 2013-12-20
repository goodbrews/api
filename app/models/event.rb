require 'app/models/beer'
require 'app/models/brewery'
require 'app/models/concerns/socialable'

class Event < ActiveRecord::Base
  include Socialable

  has_and_belongs_to_many :beers
  has_and_belongs_to_many :breweries

  before_destroy { [beers, breweries].each(&:clear) }
end
