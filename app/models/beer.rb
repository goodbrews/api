class Beer < ActiveRecord::Base
  include Sluggable

  has_and_belongs_to_many :ingredients
  has_and_belongs_to_many :breweries
  belongs_to :style

  before_destroy { ingredients.clear and breweries.clear }
end
