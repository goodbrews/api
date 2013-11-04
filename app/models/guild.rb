require 'app/models/brewery'
require 'app/models/concerns/socialable'

class Guild < ActiveRecord::Base
  include Socialable

  has_and_belongs_to_many :breweries

  before_destroy { breweries.clear }
end
