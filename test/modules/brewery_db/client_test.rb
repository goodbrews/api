require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  before :each do
    @client = BreweryDB::Client.new
  end

  it 'must parse a JSON response from BreweryDB' do
    json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'breweries.json'))
    stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

    response = @client.get('/breweries')
    response.body.must_equal JSON.parse(json)
  end

  it 'must handle errors from BreweryDB' do
    json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'error.json'))
    stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json, status: [404, "Not Found Error"])

    lambda { @client.get('/beer/NOPE') }.must_raise(BreweryDB::Client::Error)
  end
end
