require 'app/models/joins/beer_ingredient'

class Ingredient < ActiveRecord::Base
  has_many :beer_ingredients, dependent: :destroy
  has_many :beers, through: :beer_ingredients
end
