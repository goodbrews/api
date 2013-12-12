require 'spec_helper'
require 'app/apis/api'

describe BreweriesAPI do
  def app
    Goodbrews::API
  end

  context 'the index action' do
    it 'returns an empty array' do
      get '/breweries'
      last_response.status.should eq(200)
      last_response.body.should eq('[]')
    end

    it 'returns a list of breweries as JSON' do
      brewery = Factory(:brewery)
      get '/breweries'

      last_response.status.should eq(200)
      last_response.body.should eq([brewery].to_json)
    end
  end
end
