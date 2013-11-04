require 'app/models/concerns/socialable'
require 'app/models/beer'
require 'app/models/location'

class Brewery < ActiveRecord::Base
  include Socialable

  has_and_belongs_to_many :beers
  has_many :locations, dependent: :destroy

  before_destroy { beers.clear }

  def to_param
    brewerydb_id
  end
end
