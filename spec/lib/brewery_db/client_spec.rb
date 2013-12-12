require 'spec_helper'
require 'brewery_db/client'

describe BreweryDB::Client do
  let(:client) { BreweryDB::Client.new }

  it 'must raise errors returned from BreweryDB' do
    VCR.use_cassette('error') do
      expect { client.get('/beer/fake') }.to raise_error
    end
  end

  it 'must append an API key to the URL' do
    VCR.use_cassette('beer') do
      client.get('/beer/TACnR2')
    end

    url = 'https://api.brewerydb.com/v2/beer/TACnR2'
    params = { query: { 'key' => ENV['BREWERY_DB_API_KEY'] } }

    expect(a_request(:get, url).with(params)).to have_been_made
  end

  it 'must parse response bodies from BreweryDB as JSON' do
    VCR.use_cassette('beer') do
      response = client.get('/beer/TACnR2')

      expect(response.body).to be_a(Hash)
      expect(response.body['data']).to be_present
    end
  end

  context 'with query parameters' do
    let(:path) { 'https://api.brewerydb.com/v2/beer/TACnR2' }

    let(:associations) do
      %w[Breweries SocialAccounts Ingredients].inject({}) do |h, assoc|
        h["with#{assoc}"] = 'Y'; h
      end
    end

    let(:query) { associations.merge('key' => ENV['BREWERY_DB_API_KEY']) }

    it 'must accept them from a params hash' do
      VCR.use_cassette('beer_with_associations') do
        client.get('/beer/TACnR2', associations)
      end

      expect(a_request(:get, path).with(query: query)).to have_been_made
    end

    it 'must accept them from a query string in the path' do
      VCR.use_cassette('beer_with_associations') do
        request_path = '/beer/TACnR2?'
        request_path << associations.to_query

        client.get(request_path)
      end

      expect(a_request(:get, path).with(query: query)).to have_been_made
    end

    it 'must merge a params hash with a query string in the path' do
      VCR.use_cassette('beer_with_associations') do
        params = associations.dup
        params.delete('withBreweries')

        client.get('/beer/TACnR2?withBreweries=Y', params)
      end

      expect(a_request(:get, path).with(query: query)).to have_been_made
    end
  end
end
