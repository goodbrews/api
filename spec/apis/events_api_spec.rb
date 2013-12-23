require 'spec_helper'
require 'app/apis/events_api'

describe EventsAPI do
  def app
    Goodbrews::API
  end

  context '/events' do
    it 'returns an empty array' do
      get '/events'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('[]')
    end

    it 'returns a list of events as JSON' do
      event = Factory(:event)
      body = EventPresenter.present([event], context: app)

      get '/events'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(body.to_json)
    end
  end

  context '/events/:id' do
    context 'without an existing event' do
      it 'returns a 404' do
        get '/events/nothing-here'

        expect(last_response.status).to eq(404)
      end
    end

    context 'with an existing event' do
      let(:event) { Factory(:event) }

      it 'returns an existing event as json' do
        body = EventPresenter.present(event, context: app)

        get "/events/#{event.to_param}"

        expect(last_response.body).to eq(body.to_json)
      end

      context '/breweries' do
        it 'returns an empty array' do
          get "/events/#{event.to_param}/breweries"

          expect(last_response.body).to eq('[]')
        end

        it 'returns breweries as JSON' do
          event.breweries << Factory(:brewery)
          body = BreweryPresenter.present(event.breweries.reload, context: app)

          get "/events/#{event.to_param}/breweries"
          expect(last_response.body).to eq(body.to_json)
        end
      end

      context '/beers' do
        it 'returns an empty array' do
          get "/events/#{event.to_param}/beers"

          expect(last_response.body).to eq('[]')
        end

        it 'returns beers as JSON' do
          event.beers << Factory(:beer)
          body = BeerPresenter.present(event.beers.reload, context: app)

          get "/events/#{event.to_param}/beers"
          expect(last_response.body).to eq(body.to_json)
        end
      end
    end
  end
end
