require 'app/models/brewery'
require 'app/presenters/brewery_presenter'

class BreweriesAPI < Crepe::API
  namespace :breweries do
    get do
      @breweries = Brewery.limit(25)

      BreweryPresenter.present(@breweries, context: self)
    end

    get '/:slug' do
      @brewery = Brewery.from_param(params[:slug])

      BreweryPresenter.present(@brewery, context: self)
    end
  end
end
