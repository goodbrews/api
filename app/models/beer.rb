class Beer < ActiveRecord::Base
  include Sluggable

  has_and_belongs_to_many :breweries

  before_destroy { breweries.clear }
end
