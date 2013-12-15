require 'app/models/brewery'
require 'app/presenters/brewery_presenter'

class BreweriesAPI < Grape::API
  namespace :breweries do
    desc "Return a list of breweries."
    params do
      optional :page,     default: 1,  type: Integer
      optional :per_page, default: 25, type: Integer
    end
    get do
      @breweries = Brewery.page(params[:page]).per(params[:per_page])

      BreweryPresenter.present(@breweries, context: self)
    end
  end
end
