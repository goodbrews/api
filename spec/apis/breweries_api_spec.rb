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
        body    = BreweryPresenter.present(brewery, context: app)

        get "/breweries/#{brewery.slug}"

        expect(last_response.body).to eq(body.to_json)
      end
    end
  end
end
