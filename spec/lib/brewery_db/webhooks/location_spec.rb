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
        expect(location).not_to be_nil
      end

      it 'assigns attributes correctly' do
        expect_equal_attributes(location, response)
      end

      it 'assigns a brewery' do
        expect(location.brewery).to eq(brewery)
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
        expect_equal_attributes(location.reload, response)
      end
    end

    context '#delete' do

    end
  end

  def expect_equal_attributes(location, attrs)
    expect(location.name).to        eq(attrs['name'])
    expect(location.category).to    eq(attrs['locationTypeDisplay'])
    expect(location).to             be_primary
    expect(location).not_to         be_in_planning
    expect(location).to             be_public
    expect(location).not_to         be_closed
    expect(location.street).to      eq(attrs['streetAddress'])
    expect(location.street2).to     eq(attrs['extendedAddress'])
    expect(location.city).to        eq(attrs['locality'])
    expect(location.region).to      eq(attrs['region'])
    expect(location.postal_code).to eq(attrs['postalCode'])
    expect(location.country).to     eq(attrs['countryIsoCode'])
    expect(location.latitude).to    eq(attrs['latitude'])
    expect(location.longitude).to   eq(attrs['longitude'])
    expect(location.phone).to       eq(attrs['phone'])
    expect(location.website).to     eq(attrs['website'])
    expect(location.hours).to       eq(attrs['hoursOfOperation'])

    expect(location.created_at).to  eq(Time.zone.parse(attrs['createDate']))
    expect(location.updated_at).to  eq(Time.zone.parse(attrs['updateDate']))
  end
end
