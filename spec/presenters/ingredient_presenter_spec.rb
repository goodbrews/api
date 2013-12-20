require 'spec_helper'
require 'app/presenters/ingredient_presenter'

describe IngredientPresenter do
  let(:ingredients) { [Factory(:ingredient), Factory(:ingredient)] }

  it 'presents an ingredient with a root key' do
    ingredient = ingredients.first

    expected = {
      'ingredient' => {
        'name'     => ingredient.name,
        'category' => ingredient.category,
      }
    }

    hash = IngredientPresenter.present(ingredients.first, context: self)

    expect(hash).to eq(expected)
  end

  it 'presents an array of ingredients without root keys' do
    expected = [
      IngredientPresenter.present(ingredients.first, context: self)['ingredient'],
      IngredientPresenter.present(ingredients.last,  context: self)['ingredient']
    ]

    expect(IngredientPresenter.present(ingredients, context: self)).to eq(expected)
  end
end
