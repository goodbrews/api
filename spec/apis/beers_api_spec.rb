require 'spec_helper'
require 'app/apis/beers_api'

describe BeersAPI do
  def app
    Goodbrews::API
  end

  context '/beers' do
    it 'returns an empty array' do
      get '/beers'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('[]')
    end

    it 'returns a list of beers as JSON' do
      beer = Factory(:beer)
      body = BeerPresenter.present([beer.reload], context: app)

      get '/beers'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(body.to_json)
    end
  end

  context '/beers/:slug' do
    context 'without an existing beer' do
      it 'returns a 404' do
        get '/beers/nothing-here'

        expect(last_response.status).to eq(404)
      end
    end

    context 'with an existing beer' do
      let(:beer) { Factory(:beer, slug: 'a-beer', breweries: []) }

      it 'returns an existing beer as json' do
        body = BeerPresenter.present(beer.reload, context: app)

        get "/beers/#{beer.slug}"

        expect(last_response.body).to eq(body.to_json)
      end

      context '/breweries' do
        it 'returns an empty array' do
          get "/beers/#{beer.slug}/breweries"

          expect(last_response.body).to eq('[]')
        end

        it 'returns breweries as JSON' do
          beer.breweries << Factory(:brewery)
          body = BreweryPresenter.present(beer.breweries.reload, context: app)

          get "/beers/#{beer.slug}/breweries"
          expect(last_response.body).to eq(body.to_json)
        end
      end

      context '/ingredients' do
        it 'returns an empty array' do
          get "/beers/#{beer.slug}/ingredients"

          expect(last_response.body).to eq('[]')
        end

        it 'returns ingredients as JSON' do
          beer.ingredients << Factory(:ingredient)
          body = IngredientPresenter.present(beer.ingredients.reload, context: app)

          get "/beers/#{beer.slug}/ingredients"
          expect(last_response.body).to eq(body.to_json)
        end
      end

      context '/events' do
        it 'returns an empty array' do
          get "/beers/#{beer.slug}/events"

          expect(last_response.body).to eq('[]')
        end

        it 'returns events as JSON' do
          beer.events << Factory(:event)
          body = EventPresenter.present(beer.events.reload, context: app)

          get "/beers/#{beer.slug}/events"
          expect(last_response.body).to eq(body.to_json)
        end
      end
    end
  end
end
