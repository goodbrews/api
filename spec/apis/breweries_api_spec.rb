require 'spec_helper'
require 'app/apis/api'

describe BreweriesAPI do
  def app
    Goodbrews::API
  end

  context 'the index action' do
    it 'returns an empty array' do
      get '/breweries'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('[]')
    end

    it 'returns a list of breweries as JSON' do
      brewery = Factory(:brewery)
      get '/breweries'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq([brewery].to_json)
    end
  end
end
