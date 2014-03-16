require 'spec_helper'
require 'app/apis/api'

describe BreweriesAPI do
  def app
    Goodbrews::API
  end

  let(:context) do
    double.tap do |d|
      allow(d).to receive(:authorized?).and_return(false)
      allow(d).to receive(:params).and_return({})
    end
  end

  context '/breweries' do
    it 'returns an empty array' do
      get '/breweries'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('{"count":0,"breweries":[]}')
    end

    it 'returns a list of breweries as JSON' do
      brewery = Factory(:brewery)
      body = BreweriesPresenter.new(Brewery.all, context: context, root: nil).present

      get '/breweries'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(body.to_json)
    end
  end

  context '/search' do
    let!(:brewery)  { Factory(:brewery) }

    it 'returns an empty array' do
      get '/breweries/search', q: SecureRandom.hex

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('{"count":0,"breweries":[]}')
    end

    it 'returns a list of breweries as JSON' do
      body = BreweriesPresenter.new(Brewery.all, context: context, root: nil).present

      get '/breweries/search', q: brewery.name

      expect(last_response.status).to eq(200)
      expect(last_response.body).to   eq(body.to_json)
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
        body = BreweryPresenter.present(brewery, context: context)

        get "/breweries/#{brewery.slug}"

        expect(last_response.body).to eq(body.to_json)
      end

      context '/beers' do
        it 'returns an empty array' do
          get "/breweries/#{brewery.slug}/beers"

          expect(last_response.body).to eq('{"count":0,"beers":[]}')
        end

        it 'returns beers as JSON' do
          brewery.save; brewery.beers << Factory(:beer)
          body = BeersPresenter.new(brewery.beers.reload, context: context, root: nil).present

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

            body = BeerPresenter.present(beer.reload, context: context)

            get "/breweries/#{brewery.slug}/beers/#{beer.slug}"
            expect(last_response.body).to eq(body.to_json)
          end
        end
      end

      context '/guilds' do
        it 'returns an empty array' do
          get "/breweries/#{brewery.slug}/guilds"

          expect(last_response.body).to eq('{"count":0,"guilds":[]}')
        end

        it 'returns guilds as JSON' do
          brewery.save; brewery.guilds << Factory(:guild)
          body = GuildsPresenter.new(brewery.guilds.reload, context: context, root: nil).present

          get "/breweries/#{brewery.slug}/guilds"
          expect(last_response.body).to eq(body.to_json)
        end
      end

      context '/events' do
        it 'returns an empty array' do
          get "/breweries/#{brewery.slug}/events"

          expect(last_response.body).to eq('{"count":0,"events":[]}')
        end

        it 'returns events as JSON' do
          brewery.save; brewery.events << Factory(:event)
          body = EventsPresenter.new(brewery.events.reload, context: context, root: nil).present

          get "/breweries/#{brewery.slug}/events"
          expect(last_response.body).to eq(body.to_json)
        end
      end

      context '/locations' do
        it 'returns an empty array' do
          get "/breweries/#{brewery.slug}/locations"

          expect(last_response.body).to eq('{"count":0,"locations":[]}')
        end

        it 'returns locations as JSON' do
          brewery.save; brewery.locations << Factory(:location)
          body = LocationsPresenter.new(brewery.locations.reload, context: context, root: nil).present

          get "/breweries/#{brewery.slug}/locations"
          expect(last_response.body).to eq(body.to_json)
        end
      end
    end
  end
end
