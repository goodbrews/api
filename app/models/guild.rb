require 'app/models/concerns/socialable'

require 'app/models/joins/brewery_guild'

class Guild < ActiveRecord::Base
  include Socialable

  has_many :brewery_guilds, dependent: :destroy
  has_many :breweries, through: :brewery_guilds

  scope :from_param, ->(id) { find_by!(brewerydb_id: id) }

  def to_param
    brewerydb_id
  end
end
