require 'app/apis/base_api'
require 'app/models/beer'
require 'app/presenters/beer_presenter'
require 'app/presenters/brewery_presenter'
require 'app/presenters/event_presenter'
require 'app/presenters/ingredient_presenter'

class BeersAPI < BaseAPI
  get { BeersPresenter.new(Beer.all, context: self, root: nil).present }

  get :top do
    TopBeersPresenter.new(Beer.top(count: 10), context: self, root: nil).present
  end

  get :search do
    params.require(:q)

    BeersPresenter.new(Beer.search(params[:q]), context: self, root: nil).present
  end

  param :slug do
    let(:beer) { Beer.from_param(params[:slug]) }

    get { BeerPresenter.new(beer, context: self).present }

    %w[like dislike cellar hide].each do |action|
      post action do
        unauthorized! unless authorized?

        if current_user.send(action, beer)
          head :created
        else
          error! :bad_request, 'User has already submitted this rating.'
        end
      end

      delete action do
        unauthorized! unless authorized?

        if current_user.send("un#{action}", beer)
          head :no_content
        else
          error! :bad_request, 'Nothing to delete.'
        end
      end
    end

    get :breweries do
      BreweriesPresenter.new(beer.breweries, context: self, root: nil).present
    end

    get :ingredients do
      IngredientsPresenter.new(beer.ingredients, context: self, root: nil).present
    end

    get :events do
      EventsPresenter.new(beer.events, context: self, root: nil).present
    end
  end
end
