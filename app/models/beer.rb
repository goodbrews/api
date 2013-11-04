require 'app/models/concerns/socialable'
require 'app/models/brewery'
require 'app/models/ingredient'
require 'app/models/style'

class Beer < ActiveRecord::Base
  include Socialable

  has_and_belongs_to_many :breweries
  has_and_belongs_to_many :ingredients
  belongs_to :style

  before_destroy { [breweries, ingredients].each(&:clear) }

  def to_param
    brewerydb_id
  end
end
