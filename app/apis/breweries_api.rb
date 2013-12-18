require 'app/apis/base_api'
require 'app/models/brewery'
require 'app/presenters/brewery_presenter'

class BreweriesAPI < BaseAPI
  namespace :breweries do
    get do
      @breweries = paginate(Brewery.all)

      BreweryPresenter.present(@breweries, context: self)
    end

    get '/:slug' do
      @brewery = Brewery.from_param(params[:slug])

      BreweryPresenter.present(@brewery, context: self)
    end
  end
end
