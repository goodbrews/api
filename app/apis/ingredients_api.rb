require 'app/apis/base_api'
require 'app/models/ingredient'
require 'app/presenters/beer_presenter'
require 'app/presenters/ingredient_presenter'

class IngredientsAPI < BaseAPI
  get do
    IngredientsPresenter.new(Ingredient.all, context: self, root: nil).present
  end

  param :id do
    let(:ingredient) { Ingredient.find(params[:id]) }

    get { IngredientPresenter.present(ingredient, context: self) }

    get :beers do
      BeersPresenter.new(ingredient.beers, context: self, root: nil).present
    end
  end
end
