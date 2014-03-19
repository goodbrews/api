require 'spec_helper'
require 'app/presenters/ingredient_presenter'

describe IngredientPresenter do
  let(:ingredient) { Factory(:ingredient) }

  it 'presents an ingredient with a root key' do
    expected = {
      'ingredient' => {
        'name'     => ingredient.name,
        'category' => ingredient.category,
        'beers'    => ingredient.beers_count
      }
    }

    hash = IngredientPresenter.present(ingredient, context: self)

    expect(hash).to eq(expected)
  end
end

describe IngredientsPresenter do
  let(:context) do
    double.tap do |d|
      allow(d).to receive(:params).and_return({})
    end
  end

  before { 2.times { Factory(:ingredient) } }

  it 'presents a collection of ingredients' do
    ingredients = Ingredient.all
    expected = {
      'count' => 2,
      'ingredients' => [
        IngredientPresenter.new(ingredients.first, context: context, root: nil).present,
        IngredientPresenter.new(ingredients.last,  context: context, root: nil).present
      ]
    }

    presented = IngredientsPresenter.new(ingredients, context: context, root: nil).present

    expect(presented['count']).to eq(expected['count'])
    expect(presented['ingredients']).to match_array(expected['ingredients'])
  end
end
