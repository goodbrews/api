class Event < ActiveRecord::Base
  include Socialable

  has_and_belongs_to_many :beers
  has_and_belongs_to_many :breweries

  before_destroy { beers.clear and breweries.clear }
end
