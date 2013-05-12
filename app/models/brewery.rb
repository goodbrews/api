class Brewery < ActiveRecord::Base
  include Sluggable

  has_and_belongs_to_many :beers

  before_destroy { beers.clear }
end
