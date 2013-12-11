require 'spec_helper'
require 'brewery_db/webhooks/location'

describe BreweryDB::Webhooks::Location do
  let(:model_id) { 'Mq24sa' }
  let(:response) do
    yaml = YAML.load_file("spec/support/vcr_cassettes/#{cassette}.yml")
    JSON.parse(yaml['http_interactions'].first['response']['body']['string'])['data']
  end

  context '#insert' do
    let(:cassette) { 'location' }
    let(:webhook) { BreweryDB::Webhooks::Location.new(id: model_id, action: 'insert') }

    context 'before we have a brewery' do
      it 'raises an OrderingError' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhooks::OrderingError)
        end
      end
    end

    context 'when we have a brewery' do
      let!(:brewery) { Factory(:brewery, brewerydb_id: response['breweryId']) }
      let(:location) { Location.find_by(brewerydb_id: model_id) }

      before { VCR.use_cassette(cassette) { webhook.process } }

      it 'creates a location' do
        location.should_not be_nil
      end

      it 'assigns attributes correctly' do
        attributes_should_be_equal(location, response)
      end

      it 'assigns a brewery' do
        location.brewery.should eq(brewery)
      end
    end
  end

  context 'with an existing location' do
    let!(:location)  { Factory(:location, brewerydb_id: model_id) }

    context '#edit' do
      let(:cassette) { 'location' }
      let(:webhook)  { BreweryDB::Webhooks::Location.new(id: model_id, action: 'edit') }

      before do
        Factory(:brewery, brewerydb_id: response['breweryId'])
        VCR.use_cassette(cassette) { webhook.process }
      end

      it 'reassigns attributes correctly' do
        attributes_should_be_equal(location.reload, response)
      end
    end

    context '#delete' do

    end
  end

  def attributes_should_be_equal(location, attrs)
    location.name.should        eq(attrs['name'])
    location.category.should    eq(attrs['locationTypeDisplay'])
    location.should             be_primary
    location.should_not         be_in_planning
    location.should             be_public
    location.should_not         be_closed
    location.street.should      eq(attrs['streetAddress'])
    location.street2.should     eq(attrs['extendedAddress'])
    location.city.should        eq(attrs['locality'])
    location.region.should      eq(attrs['region'])
    location.postal_code.should eq(attrs['postalCode'])
    location.country.should     eq(attrs['countryIsoCode'])
    location.latitude.should    eq(attrs['latitude'])
    location.longitude.should   eq(attrs['longitude'])
    location.phone.should       eq(attrs['phone'])
    location.website.should     eq(attrs['website'])
    location.hours.should       eq(attrs['hoursOfOperation'])

    location.created_at.should  eq(Time.zone.parse(attrs['createDate']))
    location.updated_at.should  eq(Time.zone.parse(attrs['updateDate']))
  end
end
