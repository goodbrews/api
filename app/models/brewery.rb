require Grape.root.join('app/models/beer')

class Brewery < ActiveRecord::Base
  has_and_belongs_to_many :beers

  before_destroy { beers.clear }

  def to_param
    brewerydb_id
  end
end
