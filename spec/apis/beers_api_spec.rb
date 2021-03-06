require 'spec_helper'
require 'app/apis/api'

describe BeersAPI do
  def app
    Goodbrews::API
  end

  let(:context) do
    double.tap do |d|
      allow(d).to receive(:authorized?).and_return(false)
      allow(d).to receive(:params).and_return({})
    end
  end

  context '/beers' do
    it 'returns an empty array' do
      get '/beers'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('{"count":0,"beers":[]}')
    end

    it 'returns a list of beers as JSON' do
      Factory(:beer)
      body = BeersPresenter.new(Beer.all, context: context, root: nil).present

      get '/beers'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(body.to_json)
    end
  end

  context '/top' do
    it 'returns an empty array' do
      get '/beers/top'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('{"beers":[]}')
    end

    it 'returns a list of beers as JSON' do
      beer = Factory(:beer)
      expect(Beer).to receive(:top).and_return([beer])
      body = TopBeersPresenter.new([beer], context: context, root: nil).present

      get '/beers/top'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(body.to_json)
    end
  end

  context '/search' do
    let!(:beer)  { Factory(:beer) }

    it 'returns an empty array' do
      get '/beers/search', q: SecureRandom.hex

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('{"count":0,"beers":[]}')
    end

    it 'returns a list of beers as JSON' do
      body = BeersPresenter.new(Beer.all, context: context, root: nil).present

      get '/beers/search', q: beer.name

      expect(last_response.status).to eq(200)
      expect(last_response.body).to   eq(body.to_json)
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
        body = BeerPresenter.present(beer.reload, context: context)

        get "/beers/#{beer.slug}"

        expect(last_response.body).to eq(body.to_json)
      end

      %w[like dislike cellar hide].each do |action|

        context "POST /#{action}" do
          context 'when unauthorized' do
            it 'should return a 401' do
              post "/beers/#{beer.slug}/#{action}"

              expect(last_response.status).to eq(401)
            end
          end

          context 'when authorized' do
            let(:user) { Factory(:user) }
            let(:auth_token) { user.auth_tokens.last }
            let(:past_action) do
              case action
                when 'like', 'dislike' then "#{action}d"
                when 'cellar' then 'cellared'
                when 'hide' then 'hidden'
              end
            end

            it 'rates the beer' do
              post "/beers/#{beer.slug}/#{action}", {}, 'HTTP_AUTHORIZATION' => "AUTH-TOKEN #{auth_token}"

              expect(last_response.status).to eq(201)
              expect(user.send("#{past_action}_beers")).to include(beer)
            end

            it 'returns a 400 if the beer was already rated' do
              user.send(action, beer)
              post "/beers/#{beer.slug}/#{action}", {}, 'HTTP_AUTHORIZATION' => "AUTH-TOKEN #{auth_token}"

              expect(last_response.status).to eq(400)
              expect(last_response.body).to eq('{"error":{"message":"User has already submitted this rating."}}')
            end
          end
        end

        context "DELETE /#{action}" do
          context 'when unauthorized' do
            it 'should return a 401' do
              delete "/beers/#{beer.slug}/#{action}"

              expect(last_response.status).to eq(401)
            end
          end

          context 'when authorized' do
            let(:user) { Factory(:user) }
            let(:auth_token) { user.auth_tokens.last }
            let(:past_action) do
              case action
                when 'like', 'dislike' then "#{action}d"
                when 'cellar' then 'cellared'
                when 'hide' then 'hidden'
              end
            end

            it 'removes a rating for the beer' do
              user.send(action, beer)
              delete "/beers/#{beer.slug}/#{action}", {}, 'HTTP_AUTHORIZATION' => "AUTH-TOKEN #{auth_token}"

              expect(last_response.status).to eq(204)
              expect(user.send("#{past_action}_beers")).not_to include(beer)
            end

            it 'returns a 400 if the beer was not already rated' do
              delete "/beers/#{beer.slug}/#{action}", {}, 'HTTP_AUTHORIZATION' => "AUTH-TOKEN #{auth_token}"

              expect(last_response.status).to eq(400)
              expect(last_response.body).to eq('{"error":{"message":"Nothing to delete."}}')
            end
          end
        end
      end

      context '/breweries' do
        it 'returns an empty array' do
          get "/beers/#{beer.slug}/breweries"

          expect(last_response.body).to eq('{"count":0,"breweries":[]}')
        end

        it 'returns breweries as JSON' do
          beer.breweries << Factory(:brewery)
          body = BreweriesPresenter.new(beer.breweries.reload, context: context, root: nil).present

          get "/beers/#{beer.slug}/breweries"
          expect(last_response.body).to eq(body.to_json)
        end
      end

      context '/ingredients' do
        it 'returns an empty array' do
          get "/beers/#{beer.slug}/ingredients"

          expect(last_response.body).to eq('{"count":0,"ingredients":[]}')
        end

        it 'returns ingredients as JSON' do
          beer.ingredients << Factory(:ingredient)
          body = IngredientsPresenter.new(beer.ingredients.reload, context: context, root: nil).present

          get "/beers/#{beer.slug}/ingredients"
          expect(last_response.body).to eq(body.to_json)
        end
      end

      context '/events' do
        it 'returns an empty array' do
          get "/beers/#{beer.slug}/events"

          expect(last_response.body).to eq('{"count":0,"events":[]}')
        end

        it 'returns events as JSON' do
          beer.events << Factory(:event)
          body = EventsPresenter.new(beer.events.reload, context: context, root: nil).present

          get "/beers/#{beer.slug}/events"
          expect(last_response.body).to eq(body.to_json)
        end
      end
    end
  end
end
