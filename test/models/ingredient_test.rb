require 'test_helper'

describe Ingredient do
  it 'must clear Beer join records before destruction' do
    beer = Factory(:beer)
    ingredient = Factory(:ingredient)
    beer.ingredients << ingredient

    beer.reload and ingredient.reload

    ingredient.destroy
    beer.reload

    beer.id.wont_be_nil
    beer.ingredients.wont_include(ingredient)
  end
end
