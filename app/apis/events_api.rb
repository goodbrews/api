require 'app/apis/base_api'
require 'app/models/event'
require 'app/presenters/beer_presenter'
require 'app/presenters/brewery_presenter'
require 'app/presenters/event_presenter'

class EventsAPI < BaseAPI
  get { EventPresenter.present(paginate(Event.all), context: self) }

  param :id do
    let(:event) { Event.from_param(params[:id]) }

    get { EventPresenter.present(event, context: self) }

    get :breweries do
      breweries = event.breweries.includes(:locations, :social_media_accounts)
      breweries = paginate(breweries)

      BreweryPresenter.present(breweries, context: self)
    end

    get :beers do
      beers = event.beers.includes(:ingredients, :social_media_accounts, :style)
      beers = paginate(beers)

      BeerPresenter.present(beers, context: self)
    end
  end
end
