class Brewery < ActiveRecord::Base
  include Sluggable

  has_and_belongs_to_many :beers
  has_and_belongs_to_many :events
  has_many :locations, dependent: :destroy

  before_destroy { beers.clear and events.clear }
end
