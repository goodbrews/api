require 'app/apis/base_api'
require 'app/models/brewery'
require 'app/presenters/brewery_presenter'
require 'app/presenters/beer_presenter'
require 'app/presenters/event_presenter'
require 'app/presenters/guild_presenter'

class BreweriesAPI < BaseAPI
  get { BreweriesPresenter.new(Brewery.all, context: self, root: nil).present }

  param :slug do
    let(:brewery) { Brewery.from_param(params[:slug]) }

    get { BreweryPresenter.present brewery, context: self }

    namespace :beers do
      get { BeersPresenter.new(brewery.beers, context: self, root: nil).present }

      param :beer_slug do
        let(:beer) { brewery.beers.from_param(params[:beer_slug]) }

        get { BeerPresenter.present beer, context: self }
      end
    end

    get :guilds do
      GuildsPresenter.new(brewery.guilds, context: self, root: nil).present
    end

    get :events do
      EventsPresenter.new(brewery.events, context: self, root: nil).present
    end

    get :locations do
      LocationPresenter.present paginate(brewery.locations), context: self
    end
  end
end
