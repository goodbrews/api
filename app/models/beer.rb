require 'app/models/concerns/socialable'
require 'app/models/brewery'
require 'app/models/style'

class Beer < ActiveRecord::Base
  include Socialable

  has_and_belongs_to_many :breweries
  belongs_to :style

  before_destroy { breweries.clear }

  def to_param
    brewerydb_id
  end
end
