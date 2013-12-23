require 'app/apis/base_api'
require 'app/models/ingredient'
require 'app/presenters/beer_presenter'
require 'app/presenters/ingredient_presenter'

class IngredientsAPI < BaseAPI
  get { IngredientPresenter.present(paginate(Ingredient.all), context: self) }

  param :id do
    let(:ingredient) { Ingredient.find(params[:id]) }

    get { IngredientPresenter.present(ingredient, context: self) }

    get :beers do
      beers = ingredient.beers.includes(:ingredients, :social_media_accounts, :style)
      beers = paginate(beers)

      BeerPresenter.present(beers, context: self)
    end
  end
end
