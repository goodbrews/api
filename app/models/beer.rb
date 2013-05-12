class Beer < ActiveRecord::Base
  include Sluggable

  has_and_belongs_to_many :ingredients
  has_and_belongs_to_many :breweries
  has_and_belongs_to_many :events
  belongs_to :style

  before_destroy { [ingredients, events, breweries].each(&:clear) }
end
