require 'app/apis/base_api'
require 'app/models/beer'
require 'app/presenters/beer_presenter'
require 'app/presenters/brewery_presenter'
require 'app/presenters/event_presenter'
require 'app/presenters/ingredient_presenter'

class BeersAPI < BaseAPI
  get do
    beers = paginate(Beer.includes(:ingredients, :social_media_accounts, :style))

    BeerPresenter.present(beers, context: self)
  end

  param :slug do
    let(:beer) { Beer.includes(:ingredients, :social_media_accounts, :style).from_param(params[:slug]) }

    get do
      BeerPresenter.present(beer, context: self)
    end

    get :breweries do
      breweries = beer.breweries.includes(:locations, :social_media_accounts)

      BreweryPresenter.present(breweries, context: self)
    end

    get :ingredients do
      IngredientPresenter.present(beer.ingredients, context: self)
    end

    get :events do
      EventPresenter.present(beer.events, context: self)
    end
  end
end
