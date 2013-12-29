require 'app/apis/base_api'
require 'app/models/beer'
require 'app/presenters/beer_presenter'
require 'app/presenters/brewery_presenter'
require 'app/presenters/event_presenter'
require 'app/presenters/ingredient_presenter'

class BeersAPI < BaseAPI
  get { BeersPresenter.new(Beer.all, context: self, root: nil).present }

  param :slug do
    let(:beer) { Beer.from_param(params[:slug]) }

    get { BeerPresenter.present beer, context: self }

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
      IngredientPresenter.present beer.ingredients, context: self
    end

    get :events do
      EventsPresenter.new(beer.events, context: self, root: nil).present
    end
  end
end
