require 'test_helper'

class LocationWebhookTest < ActiveSupport::TestCase
  context '#insert' do
    before :each do
      @json       = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'location.json'))
      @attributes = JSON.parse(@json)['data']
      @brewery = Factory(:brewery, brewerydb_id: @attributes['breweryId'])
      stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: @json)

      @webhook = BreweryDB::Webhooks::Location.new({
        id: @attributes['id'],
        action: 'insert'
      })
    end

    it 'must create a new location' do
      @webhook.process
      Location.count.must_equal 1
    end

    it 'must correctly assign attributes to a location' do
      @webhook.process
      location = Location.find_by(brewerydb_id: @attributes['id'])

      assert_attributes_equal(location, @attributes)
      location.brewery.must_equal @brewery
    end
  end

  context '#edit' do
    before :each do
      @json       = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'location.json'))
      @attributes = JSON.parse(@json)['data']
      stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: @json)
      @brewery = Factory(:brewery, brewerydb_id: @attributes['breweryId'])

      @webhook = BreweryDB::Webhooks::Location.new({
        id: @attributes['id'],
        action: 'edit'
      })

      @location = Factory(:location, brewerydb_id: @attributes['id'], brewery: @brewery)
    end

    it 'should reassign changed attributes' do
      @webhook.process and @location.reload
      assert_attributes_equal(@location, @attributes)
    end
  end

  context '#delete' do
    it 'should delete the location with the passed brewerydb_id' do
      webhook = BreweryDB::Webhooks::Location.new({
        id: 'dAvID',
        action: 'delete'
      })

      location = Factory(:location, brewerydb_id: 'dAvID')
      webhook.process

      lambda { location.reload }.must_raise(ActiveRecord::RecordNotFound)
    end
  end

  private
    def assert_attributes_equal(location, attributes)
      location.name.must_equal        attributes['name']
      location.category.must_equal    attributes['locationTypeDisplay']
      location.wont_be :primary?
      location.wont_be :in_planning?
      location.must_be :public?
      location.wont_be :closed?

      location.street.must_equal      attributes['streetAddress']
      location.street2.must_equal     attributes['extendedAddress']
      location.city.must_equal        attributes['locality']
      location.region.must_equal      attributes['region']
      location.postal_code.must_equal attributes['postalCode']
      location.country.must_equal     attributes['countryIsoCode']

      location.latitude.must_equal    attributes['latitude']
      location.longitude.must_equal   attributes['longitude']

      location.phone.must_equal       attributes['phone']
      location.website.must_equal     attributes['website']
      location.hours.must_equal       attributes['hoursOfOperation']

      location.created_at.must_equal  Time.zone.parse(attributes['createDate'])
      location.updated_at.must_equal  Time.zone.parse(attributes['updateDate'])
    end
end
