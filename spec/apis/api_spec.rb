require 'spec_helper'
require 'app/apis/api'

describe Goodbrews::API do
  def app
    Goodbrews::API
  end

  context '/' do
    it 'returns a hash of explorable links' do
      links = {
        _links: {
          beers:       { href: '/beers' },
          breweries:   { href: '/breweries' },
          events:      { href: '/events' },
          guilds:      { href: '/guilds' },
          ingredients: { href: '/ingredients' }
        }
      }

      get '/'

      expect(last_response.body).to eq(links.to_json)
    end
  end

  context '/*catchall' do
    it 'should return a 404 for matches' do
      get '/nothing-here'

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq '{"error":{"message":"Not Found"}}'
    end
  end
end
