class Style < ActiveRecord::Base
  include Sluggable

  has_many :beers
end
