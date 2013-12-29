require 'app/apis/base_api'
require 'app/models/event'
require 'app/presenters/beer_presenter'
require 'app/presenters/brewery_presenter'
require 'app/presenters/event_presenter'

class EventsAPI < BaseAPI
  get { EventsPresenter.new(Event.all, context: self, root: nil).present }

  param :id do
    let(:event) { Event.from_param(params[:id]) }

    get { EventPresenter.present event, context: self }

    get :breweries do
      BreweriesPresenter.new(event.breweries, context: self, root: nil).present
    end

    get :beers do
      BeersPresenter.new(event.beers, context: self, root: nil).present
    end
  end
end
