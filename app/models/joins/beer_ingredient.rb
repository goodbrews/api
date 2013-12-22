require 'app/models/beer'
require 'app/models/ingredient'

class BeerIngredient < ActiveRecord::Base
  belongs_to :beer,       counter_cache: 'ingredients_count'
  belongs_to :ingredient, counter_cache: 'beers_count'
end
