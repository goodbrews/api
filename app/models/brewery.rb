class Brewery < ActiveRecord::Base
  include Sluggable

  has_and_belongs_to_many :beers
  has_many :locations, dependent: :destroy

  before_destroy { beers.clear }
end
