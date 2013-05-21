class Guild < ActiveRecord::Base
  include Socialable

  has_and_belongs_to_many :breweries
end
