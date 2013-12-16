require 'app/models/brewery'
require 'app/presenters/brewery_presenter'

class BreweriesAPI < Grape::API
  namespace :breweries do
    desc "Return a list of breweries."
    paginate per_page: 25
    get do
      @breweries = paginate(Brewery.all)

      BreweryPresenter.present(@breweries, context: self)
    end

    desc "Return one brewery."
    params do
      requires :slug, type: String
    end
    route_param :slug do
      get do
        @brewery = Brewery.from_param(params[:slug])

        BreweryPresenter.present(@brewery, context: self)
      end
    end
  end
end
