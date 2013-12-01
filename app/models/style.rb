require 'app/models/concerns/sluggable'
require 'app/models/beer'

class Style < ActiveRecord::Base
  include Sluggable

  has_many :beers
end
