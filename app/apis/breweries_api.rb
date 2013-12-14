require 'app/models/brewery'
require 'app/presenters/brewery_presenter'

class BreweriesAPI < Grape::API
  namespace :breweries do
    desc "Return a list of breweries."
    get do
      @breweries = Brewery.all

      BreweryPresenter.present(@breweries, context: self)
    end
  end
end
