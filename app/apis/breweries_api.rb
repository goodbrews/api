require 'app/apis/base_api'
require 'app/models/brewery'
require 'app/presenters/brewery_presenter'
require 'app/presenters/beer_presenter'

class BreweriesAPI < BaseAPI
  get do
    breweries = paginate(Brewery.all)

    BreweryPresenter.present(breweries, context: self)
  end

  param :slug do
    let(:brewery) { Brewery.from_param(params[:slug]) }

    get do
      BreweryPresenter.present(brewery, context: self)
    end

    get :beers do
      beers = paginate(brewery.beers.includes(:style, :ingredients, :social_media_accounts))

      BeerPresenter.present(beers, context: self)
    end
  end
end
