require 'spec_helper'
require 'lib/brewery_db/webhook/shared_examples/social_accounts'
require 'brewery_db/webhook/event'

describe BreweryDB::Webhook::Event do
  let(:model_id)  { 'TGtEbk' }
  let(:cassette) { 'event' }
  let(:yaml) { YAML.load_file("spec/support/vcr_cassettes/#{cassette}.yml") }
  let(:response) { JSON.parse(yaml['http_interactions'].first['response']['body']['string'])['data'] }
  let(:brewery_response) { JSON.parse(yaml['http_interactions'].second['response']['body']['string'])['data'] }
  let(:beer_response) { JSON.parse(yaml['http_interactions'].third['response']['body']['string'])['data'] }

  it_behaves_like 'a webhook that updates social accounts'

  context '#insert' do
    let(:webhook) { BreweryDB::Webhook::Event.new(id: model_id, action: 'insert') }

    context 'before we have breweries or beers' do
      it 'raises an OrderingError' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhook::OrderingError)
        end
      end
    end

    context 'when we only have breweries' do
      before do
        brewery_response.map { |b| Factory(:brewery, brewerydb_id: b['breweryId']) }
      end

      it 'raises an OrderingError' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhook::OrderingError)
        end
      end
    end

    context 'when we only have beers' do
      before do
        beer_response.map { |b| Factory(:beer, brewerydb_id: b['beerId']) }
      end

      it 'raises an OrderingError' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhook::OrderingError)
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
        attributes_should_be_equal(event, response)
      end

      it 'assigns breweries' do
        event.breweries.count.should eq(brewery_response.count)
      end

      it 'assigns beers' do
        event.beers.count.should eq(beer_response.count)
      end

      it 'assigns social media accounts' do
        event.social_media_accounts.count.should eq(social_account_response.count)
      end
    end
  end

  context 'with an existing event' do
    let!(:event)  { Factory(:event, brewerydb_id: model_id) }

    context '#edit' do
      let(:webhook) { BreweryDB::Webhook::Event.new(id: model_id, action: 'edit') }

      before do
        brewery_response.map { |b| Factory(:brewery, brewerydb_id: b['breweryId']) }
        beer_response.map    { |b| Factory(:beer,    brewerydb_id: b['beerId']) }

        VCR.use_cassette(cassette) { webhook.process }
      end

      it 'reassigns attributes correctly' do
        attributes_should_be_equal(event.reload, response)
      end
    end

    context '#brewery_insert' do
      let(:webhook) { BreweryDB::Webhook::Event.new(id: model_id, action: 'edit', sub_action: 'brewery_insert') }

      it 'raises an OrderingError if we do not have the breweries yet' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhook::OrderingError)
        end
      end

      it 'assigns breweries if we have them' do
        brewery_response.each { |b| Factory(:brewery, brewerydb_id: b['breweryId']) }
        VCR.use_cassette(cassette) { webhook.process }

        event.breweries.count.should eq(brewery_response.count)
      end
    end

    context '#brewery_delete' do
      let(:webhook) { BreweryDB::Webhook::Event.new(id: model_id, action: 'edit', sub_action: 'brewery_delete') }

      it 'removes breweries from an association' do
        brewery = Factory(:brewery)
        breweries = brewery_response.map { |b| Factory(:brewery, brewerydb_id: b['breweryId']) }
        breweries << brewery
        event.breweries = breweries

        VCR.use_cassette(cassette) { webhook.process }
        event.reload

        event.breweries.count.should eq(brewery_response.count)
        event.breweries.should_not include(brewery)
      end
    end

    context '#brewery_edit' do
      let(:webhook) { BreweryDB::Webhook::Event.new(id: model_id, action: 'edit', sub_action: 'brewery_edit') }

      it 'acts as a noop, returning true' do
        webhook.process.should be_true
      end
    end

    context '#beer_insert' do
      let(:webhook) { BreweryDB::Webhook::Event.new(id: model_id, action: 'edit', sub_action: 'beer_insert') }

      it 'raises an OrderingError if we do not have the beers yet' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhook::OrderingError)
        end
      end

      it 'assigns beers if we have them' do
        beer_response.each { |b| Factory(:beer, brewerydb_id: b['beerId']) }
        VCR.use_cassette(cassette) { webhook.process }

        event.beers.count.should eq(beer_response.count)
      end
    end

    context '#beer_delete' do
      let(:webhook) { BreweryDB::Webhook::Event.new(id: model_id, action: 'edit', sub_action: 'beer_delete') }

      it 'removes beers from an association' do
        beer  = Factory(:beer)
        beers = beer_response.map { |b| Factory(:beer, brewerydb_id: b['beerId']) }
        beers << beer
        event.beers = beers

        VCR.use_cassette(cassette) { webhook.process }
        event.reload

        event.beers.count.should eq(beer_response.count)
        event.beers.should_not include(beer)
      end
    end

    context '#beer_edit' do
      let(:webhook) { BreweryDB::Webhook::Event.new(id: model_id, action: 'edit', sub_action: 'beer_edit') }

      it 'acts as a noop, returning true' do
        webhook.process.should be_true
      end
    end
  end

  def attributes_should_be_equal(event, attrs)
    event.name.should        eq(attrs['name'])
    event.year.should        eq(attrs['year'].to_i)
    event.description.should eq(attrs['description'])
    event.category.should    eq(attrs['typeDisplay'])
    event.start_date.should  eq(Date.parse(attrs['startDate']))
    event.end_date.should    eq(Date.parse(attrs['endDate']))
    event.hours.should       eq(attrs['time'])
    event.price.should       eq(attrs['price'])
    event.venue.should       eq(attrs['venueName'])
    event.street.should      eq(attrs['streetAddress'])
    event.street2.should     eq(attrs['extendedAddress'])
    event.city.should        eq(attrs['locality'])
    event.region.should      eq(attrs['region'])
    event.postal_code.should eq(attrs['postalCode'])
    event.country.should     eq(attrs['countryIsoCode'])
    event.latitude.should    eq(attrs['latitude'])
    event.longitude.should   eq(attrs['longitude'])
    event.website.should     eq(attrs['website'])
    event.phone.should       eq(attrs['phone'])

    event.created_at.should  eq(Time.zone.parse(attrs['createDate']))
    event.updated_at.should  eq(Time.zone.parse(attrs['updateDate']))

    event.image_id.should eq(attrs['images']['icon'].match(/upload_(\w+)-icon/)[1])
  end
end
