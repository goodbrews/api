class Beer < ActiveRecord::Base
  has_and_belongs_to_many :breweries

  before_destroy { breweries.clear }
end
