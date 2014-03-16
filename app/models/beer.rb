require 'app/models/concerns/socialable'
require 'app/models/concerns/sluggable'
require 'app/models/joins/beer_brewery'
require 'app/models/joins/beer_event'
require 'app/models/joins/beer_ingredient'
require 'app/models/style'

class Beer < ActiveRecord::Base
  include Socialable
  include Sluggable
  include PgSearch

  pg_search_scope :search, against: {
                             name:        'A',
                             description: 'B'
                           },
                           using: {
                             tsearch: {
                               prefix:     true,
                               any_word:   true,
                               dictionary: 'english'
                             },
                             trigram: {
                               threshold: 0.5
                             }
                           },
                           associated_against: {
                             breweries:   :name,
                             ingredients: :name,
                             style:       :name
                           },
                           ignoring: :accents

  has_many :beer_breweries, dependent: :destroy
  has_many :breweries, through: :beer_breweries

  has_many :beer_events, dependent: :destroy
  has_many :events, through: :beer_events

  has_many :beer_ingredients, dependent: :destroy
  has_many :ingredients, through: :beer_ingredients

  belongs_to :style, counter_cache: true

  default_scope { includes(:ingredients, :social_media_accounts, :style) }
end
