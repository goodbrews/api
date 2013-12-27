require 'app/apis/base_api'
require 'app/models/ingredient'
require 'app/presenters/beer_presenter'
require 'app/presenters/ingredient_presenter'

class IngredientsAPI < BaseAPI
  get { IngredientPresenter.present(paginate(Ingredient.all), context: self) }

  param :id do
    let(:ingredient) { Ingredient.find(params[:id]) }

    get { IngredientPresenter.present(ingredient, context: self) }

    get(:beers) { BeerPresenter.present paginate(ingredient.beers), context: self }
  end
end
