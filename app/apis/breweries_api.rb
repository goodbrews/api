require 'app/apis/base_api'
require 'app/models/brewery'
require 'app/presenters/brewery_presenter'
require 'app/presenters/beer_presenter'
require 'app/presenters/event_presenter'
require 'app/presenters/guild_presenter'

class BreweriesAPI < BaseAPI
  get { BreweryPresenter.present paginate(Brewery.all), context: self }

  param :slug do
    let(:brewery) { Brewery.from_param(params[:slug]) }

    get { BreweryPresenter.present brewery, context: self }

    namespace :beers do
      get { BeerPresenter.present paginate(brewery.beers), context: self }

      param :beer_slug do
        let(:beer) { brewery.beers.from_param(params[:beer_slug]) }

        get { BeerPresenter.present beer, context: self }
      end
    end

    get :guilds do
      guilds = paginate(brewery.guilds.includes(:social_media_accounts))

      GuildPresenter.present guilds, context: self
    end

    get :events do
      events = paginate(brewery.events.includes(:social_media_accounts))

      EventPresenter.present events, context: self
    end

    get :locations do
      LocationPresenter.present paginate(brewery.locations), context: self
    end
  end
end
