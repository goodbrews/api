require 'spec_helper'
require 'app/apis/api'

describe Goodbrews::API do
  def app
    Goodbrews::API
  end

  context '/' do
    context 'for a JSON request' do
      it 'returns a hash of explorable links' do
        links = {
          _links: {
            authorizations: { href: '/authorizations', methods: %w[POST DELETE] },
            beers:          { href: '/beers' },
            breweries:      { href: '/breweries' },
            events:         { href: '/events' },
            guilds:         { href: '/guilds' },
            ingredients:    { href: '/ingredients' },
            styles:         { href: '/styles' }
          }
        }

        get '/', {}, 'HTTP_ACCEPT' => 'application/json'

        expect(last_response.body).to eq(links.to_json)
      end
    end

    context 'for an HTML request' do
      it 'redirects to the API documentation' do
        url = 'https://goodbrews.github.com/api'
        get '/', {}, 'HTTP_ACCEPT' => 'text/html'

        expect(last_response.status).to eq(303)
        expect(last_response.headers['Location']).to eq(url)
      end
    end
  end
end
