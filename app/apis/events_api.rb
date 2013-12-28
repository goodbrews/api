require 'app/apis/base_api'
require 'app/models/event'
require 'app/presenters/beer_presenter'
require 'app/presenters/brewery_presenter'
require 'app/presenters/event_presenter'

class EventsAPI < BaseAPI
  get { EventPresenter.present paginate(Event.all), context: self }

  param :id do
    let(:event) { Event.from_param(params[:id]) }

    get { EventPresenter.present event, context: self }

    get :breweries do
      BreweryPresenter.present event.breweries, context: self
    end

    get :beers do
      BeersPresenter.new(event.beers, context: self, root: nil).present
    end
  end
end
