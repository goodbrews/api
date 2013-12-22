require 'spec_helper'
require 'app/apis/breweries_api'

describe BreweriesAPI do
  def app
    Goodbrews::API
  end

  context '/breweries' do
    it 'returns an empty array' do
      get '/breweries'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('[]')
    end

    it 'returns a list of breweries as JSON' do
      brewery = Factory(:brewery)
      body = BreweryPresenter.present([brewery], context: app)

      get '/breweries'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(body.to_json)
    end
  end

  context '/breweries/:slug' do
    context 'without an existing brewery' do
      it 'returns a 404' do
        get '/breweries/nothing-here'

        expect(last_response.status).to eq(404)
      end
    end

    context 'with an existing brewery' do
      let(:brewery) { Factory.build(:brewery, slug: 'a-brewery') }
      before { expect(Brewery).to receive(:from_param).and_return(brewery) }

      it 'returns an existing brewery as json' do
        body = BreweryPresenter.present(brewery, context: app)

        get "/breweries/#{brewery.slug}"

        expect(last_response.body).to eq(body.to_json)
      end

      context '/beers' do
        it 'returns an empty array' do
          get "/breweries/#{brewery.slug}/beers"

          expect(last_response.body).to eq('[]')
        end

        it 'returns beers as JSON' do
          brewery.save; brewery.beers << Factory(:beer)
          body = BeerPresenter.present(brewery.beers.reload, context: app)

          get "/breweries/#{brewery.slug}/beers"
          expect(last_response.body).to eq(body.to_json)
        end

        context '/:beer_slug' do
          it 'returns a 404 if the beer doesnt exist' do
            get "/breweries/#{brewery.slug}/beers/nothing-here"

            expect(last_response.status).to eq(404)
          end

          it 'returns a beer as JSON' do
            brewery.save
            beer = Factory(:beer)
            brewery.beers << beer

            body = BeerPresenter.present(beer.reload)

            get "/breweries/#{brewery.slug}/beers/#{beer.slug}"
            expect(last_response.body).to eq(body.to_json)
          end
        end
      end

      context '/guilds' do
        it 'returns an empty array' do
          get "/breweries/#{brewery.slug}/guilds"

          expect(last_response.body).to eq('[]')
        end

        it 'returns guilds as JSON' do
          brewery.save; brewery.guilds << Factory(:guild)
          body = GuildPresenter.present(brewery.guilds.reload, context: app)

          get "/breweries/#{brewery.slug}/guilds"
          expect(last_response.body).to eq(body.to_json)
        end
      end

      context '/events' do
        it 'returns an empty array' do
          get "/breweries/#{brewery.slug}/events"

          expect(last_response.body).to eq('[]')
        end

        it 'returns events as JSON' do
          brewery.save; brewery.events << Factory(:event)
          body = EventPresenter.present(brewery.events.reload, context: app)

          get "/breweries/#{brewery.slug}/events"
          expect(last_response.body).to eq(body.to_json)
        end
      end

      context '/locations' do
        it 'returns an empty array' do
          get "/breweries/#{brewery.slug}/locations"

          expect(last_response.body).to eq('[]')
        end

        it 'returns locations as JSON' do
          brewery.save; brewery.locations << Factory(:location)
          body = LocationPresenter.present(brewery.locations.reload, context: app)

          get "/breweries/#{brewery.slug}/locations"
          expect(last_response.body).to eq(body.to_json)
        end
      end
    end
  end
end
