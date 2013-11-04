require 'app/models/beer'

class Style < ActiveRecord::Base
  has_many :beers
end
