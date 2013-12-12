require 'spec_helper'
require 'lib/brewery_db/webhooks/shared_examples/social_accounts'
require 'brewery_db/webhooks/event'

describe BreweryDB::Webhooks::Event do
  let(:model_id)  { 'TGtEbk' }
  let(:cassette) { 'event' }
  let(:yaml) { YAML.load_file("spec/support/vcr_cassettes/#{cassette}.yml") }
  let(:response) { JSON.parse(yaml['http_interactions'].first['response']['body']['string'])['data'] }
  let(:brewery_response) { JSON.parse(yaml['http_interactions'].second['response']['body']['string'])['data'] }
  let(:beer_response) { JSON.parse(yaml['http_interactions'].third['response']['body']['string'])['data'] }

  it_behaves_like 'a webhook that updates social accounts'

  context '#insert' do
    let(:webhook) { BreweryDB::Webhooks::Event.new(id: model_id, action: 'insert') }

    context 'before we have breweries or beers' do
      it 'raises an OrderingError' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhooks::OrderingError)
        end
      end
    end

    context 'when we only have breweries' do
      before do
        brewery_response.map { |b| Factory(:brewery, brewerydb_id: b['breweryId']) }
      end

      it 'raises an OrderingError' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhooks::OrderingError)
        end
      end
    end

    context 'when we only have beers' do
      before do
        beer_response.map { |b| Factory(:beer, brewerydb_id: b['beerId']) }
      end

      it 'raises an OrderingError' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhooks::OrderingError)
        end
      end
    end

    context 'when we have both breweries and beers' do
      let(:social_account_response) { JSON.parse(yaml['http_interactions'].last['response']['body']['string'])['data'] }
      let(:event) { Event.find_by(brewerydb_id: model_id) }

      before do
        brewery_response.map { |b| Factory(:brewery, brewerydb_id: b['breweryId']) }
        beer_response.map    { |b| Factory(:beer,    brewerydb_id: b['beerId']) }

        VCR.use_cassette(cassette) { webhook.process }
      end

      it 'assigns attributes correctly' do
        expect_equal_attributes(event, response)
      end

      it 'assigns breweries' do
        expect(event.breweries.count).to eq(brewery_response.count)
      end

      it 'assigns beers' do
        expect(event.beers.count).to eq(beer_response.count)
      end

      it 'assigns social media accounts' do
        expect(event.social_media_accounts.count).to eq(social_account_response.count)
      end
    end
  end

  context 'with an existing event' do
    let!(:event)  { Factory(:event, brewerydb_id: model_id) }

    context '#edit' do
      let(:webhook) { BreweryDB::Webhooks::Event.new(id: model_id, action: 'edit') }

      before do
        brewery_response.map { |b| Factory(:brewery, brewerydb_id: b['breweryId']) }
        beer_response.map    { |b| Factory(:beer,    brewerydb_id: b['beerId']) }

        VCR.use_cassette(cassette) { webhook.process }
      end

      it 'reassigns attributes correctly' do
        expect_equal_attributes(event.reload, response)
      end
    end

    context '#brewery_insert' do
      let(:webhook) { BreweryDB::Webhooks::Event.new(id: model_id, action: 'edit', sub_action: 'brewery_insert') }

      it 'raises an OrderingError if we do not have the breweries yet' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhooks::OrderingError)
        end
      end

      it 'assigns breweries if we have them' do
        brewery_response.each { |b| Factory(:brewery, brewerydb_id: b['breweryId']) }
        VCR.use_cassette(cassette) { webhook.process }

        expect(event.breweries.count).to eq(brewery_response.count)
      end
    end

    context '#brewery_delete' do
      let(:webhook) { BreweryDB::Webhooks::Event.new(id: model_id, action: 'edit', sub_action: 'brewery_delete') }

      it 'removes breweries from an association' do
        brewery = Factory(:brewery)
        breweries = brewery_response.map { |b| Factory(:brewery, brewerydb_id: b['breweryId']) }
        breweries << brewery
        event.breweries = breweries

        VCR.use_cassette(cassette) { webhook.process }
        event.reload

        expect(event.breweries.count).to eq(brewery_response.count)
        expect(event.breweries).not_to include(brewery)
      end
    end

    context '#brewery_edit' do
      let(:webhook) { BreweryDB::Webhooks::Event.new(id: model_id, action: 'edit', sub_action: 'brewery_edit') }

      it 'acts as a noop, returning true' do
        expect(webhook.process).to be_true
      end
    end

    context '#beer_insert' do
      let(:webhook) { BreweryDB::Webhooks::Event.new(id: model_id, action: 'edit', sub_action: 'beer_insert') }

      it 'raises an OrderingError if we do not have the beers yet' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhooks::OrderingError)
        end
      end

      it 'assigns beers if we have them' do
        beer_response.each { |b| Factory(:beer, brewerydb_id: b['beerId']) }
        VCR.use_cassette(cassette) { webhook.process }

        expect(event.beers.count).to eq(beer_response.count)
      end
    end

    context '#beer_delete' do
      let(:webhook) { BreweryDB::Webhooks::Event.new(id: model_id, action: 'edit', sub_action: 'beer_delete') }

      it 'removes beers from an association' do
        beer  = Factory(:beer)
        beers = beer_response.map { |b| Factory(:beer, brewerydb_id: b['beerId']) }
        beers << beer
        event.beers = beers

        VCR.use_cassette(cassette) { webhook.process }
        event.reload

        expect(event.beers.count).to eq(beer_response.count)
        expect(event.beers).not_to include(beer)
      end
    end

    context '#beer_edit' do
      let(:webhook) { BreweryDB::Webhooks::Event.new(id: model_id, action: 'edit', sub_action: 'beer_edit') }

      it 'acts as a noop, returning true' do
        expect(webhook.process).to be_true
      end
    end
  end

  def expect_equal_attributes(event, attrs)
    expect(event.name).to        eq(attrs['name'])
    expect(event.year).to        eq(attrs['year'].to_i)
    expect(event.description).to eq(attrs['description'])
    expect(event.category).to    eq(attrs['typeDisplay'])
    expect(event.start_date).to  eq(Date.parse(attrs['startDate']))
    expect(event.end_date).to    eq(Date.parse(attrs['endDate']))
    expect(event.hours).to       eq(attrs['time'])
    expect(event.price).to       eq(attrs['price'])
    expect(event.venue).to       eq(attrs['venueName'])
    expect(event.street).to      eq(attrs['streetAddress'])
    expect(event.street2).to     eq(attrs['extendedAddress'])
    expect(event.city).to        eq(attrs['locality'])
    expect(event.region).to      eq(attrs['region'])
    expect(event.postal_code).to eq(attrs['postalCode'])
    expect(event.country).to     eq(attrs['countryIsoCode'])
    expect(event.latitude).to    eq(attrs['latitude'])
    expect(event.longitude).to   eq(attrs['longitude'])
    expect(event.website).to     eq(attrs['website'])
    expect(event.phone).to       eq(attrs['phone'])

    expect(event.created_at).to  eq(Time.zone.parse(attrs['createDate']))
    expect(event.updated_at).to  eq(Time.zone.parse(attrs['updateDate']))

    expect(event.image_id).to eq(attrs['images']['icon'].match(/upload_(\w+)-icon/)[1])
  end
end
