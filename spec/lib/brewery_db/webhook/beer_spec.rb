require 'spec_helper'
require 'brewery_db/webhook/beer'

describe BreweryDB::Webhook::Beer do
  let(:beer_id)  { 'TACnR2' }
  let(:response) do
    yaml = YAML.load_file("spec/support/vcr_cassettes/#{cassette}.yml")
    JSON.parse(yaml['http_interactions'].first['response']['body']['string'])['data']
  end

  context '#insert' do
    let(:cassette) { 'beer_with_associations' }
    let(:webhook) { BreweryDB::Webhook::Beer.new(id: beer_id, action: 'insert') }
    let!(:style)  { Factory(:style, id: response['styleId']) }

    context 'before we have breweries' do
      it 'raises an OrderingError' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhook::Beer::OrderingError)
        end
      end
    end

    context 'when we have breweries' do
      let(:beer) { Beer.find_by(brewerydb_id: beer_id) }
      before do
        response['breweries'].map { |b| Factory(:brewery, brewerydb_id: b['id']) }
        VCR.use_cassette(cassette) { webhook.process }
      end

      it 'creates a beer' do
        beer.should_not be_nil
      end

      it 'assigns attributes correctly' do
        attributes_should_be_equal(beer, response)
      end

      it 'assigns a style' do
        beer.style.should eq(style)
      end

      it 'assigns breweries' do
        beer.breweries.count.should eq(response['breweries'].count)
      end

      it 'creates social media accounts' do
        beer.social_media_accounts.count.should eq(response['socialAccounts'].count)
      end

      it 'creates ingredients' do
        beer.ingredients.count.should eq(response['ingredients'].count)
      end
    end
  end

  context 'with an existing beer' do
    let!(:beer)  { Factory(:beer, brewerydb_id: beer_id) }

    context '#edit' do
      let(:cassette) { 'beer_with_associations' }
      let(:webhook) { BreweryDB::Webhook::Beer.new(id: beer_id, action: 'edit') }

      before do
        Factory(:style, id: response['styleId'])
        VCR.use_cassette(cassette) { webhook.process }
      end

      it 'reassigns attributes correctly' do
        attributes_should_be_equal(beer.reload, response)
      end
    end

    context '#brewery_insert' do
      let(:cassette) { 'beer_breweries' }
      let(:webhook) { BreweryDB::Webhook::Beer.new(id: beer_id, action: 'edit', sub_action: 'brewery_insert') }

      it 'raises an OrderingError if we do not have the breweries yet' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhook::Beer::OrderingError)
        end
      end

      it 'assigns breweries if we have them' do
        response.each { |b| Factory(:brewery, brewerydb_id: b['id']) }
        VCR.use_cassette(cassette) { webhook.process }

        beer.breweries.count.should eq(response.count)
      end
    end

    context '#brewery_delete' do
      let(:cassette) { 'beer_breweries' }
      let(:webhook) { BreweryDB::Webhook::Beer.new(id: beer_id, action: 'edit', sub_action: 'brewery_delete') }

      it 'removes breweries from an association' do
        brewery = Factory(:brewery)
        breweries = response.map { |b| Factory(:brewery, brewerydb_id: b['id']) }
        breweries << brewery
        beer.breweries = breweries

        VCR.use_cassette(cassette) { webhook.process }
        beer.reload

        beer.breweries.count.should eq(response.count)
        beer.breweries.should_not include(brewery)
      end
    end

    context '#brewery_edit' do
      let(:webhook) { BreweryDB::Webhook::Beer.new(id: beer_id, action: 'edit', sub_action: 'brewery_edit') }

      it 'acts as a noop, returning true' do
        webhook.process.should be_true
      end
    end

    context '#event_insert' do
      let(:cassette) { 'beer_events' }
      let(:webhook) { BreweryDB::Webhook::Beer.new(id: beer_id, action: 'edit', sub_action: 'event_insert') }

      it 'raises an OrderingError if we do not have the events yet' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhook::Beer::OrderingError)
        end
      end

      it 'assigns events if we have them' do
        response.each { |e| Factory(:event, brewerydb_id: e['eventId']) }
        VCR.use_cassette(cassette) { webhook.process }

        beer.events.count.should eq(response.count)
      end
    end

    context '#event_delete' do
      let(:cassette) { 'beer_events' }
      let(:webhook) { BreweryDB::Webhook::Beer.new(id: beer_id, action: 'edit', sub_action: 'event_delete') }

      it 'removes events from an association' do
        event = Factory(:event)
        events = response.map { |e| Factory(:event, brewerydb_id: e['eventId']) }
        events << event
        beer.events = events

        VCR.use_cassette(cassette) { webhook.process }
        beer.reload

        beer.events.count.should eq(response.count)
        beer.events.should_not include(event)
      end
    end

    context '#event_edit' do
      let(:webhook) { BreweryDB::Webhook::Beer.new(id: beer_id, action: 'edit', sub_action: 'event_edit') }

      it 'acts as a noop, returning true' do
        webhook.process.should be_true
      end
    end

    context '#socialaccount_insert' do
      let(:cassette) { 'beer_social_media_accounts' }
      let(:webhook) { BreweryDB::Webhook::Beer.new(id: beer_id, action: 'edit', sub_action: 'socialaccount_insert') }

      before { VCR.use_cassette(cassette) { webhook.process } }

      it 'creates and assigns social_media_accounts' do
        beer.social_media_accounts.count.should eq(response.count)
      end
    end

    context '#socialaccount_delete' do
      let(:cassette) { 'beer_social_media_accounts' }
      let(:webhook) { BreweryDB::Webhook::Beer.new(id: beer_id, action: 'edit', sub_action: 'socialaccount_delete') }

      it 'destroys social_media_accounts' do
        accounts = response.map { |a| Factory(:social_media_account, website: a['name'], socialable: beer) }
        account = Factory(:social_media_account, website: 'BeerAdvocate', socialable: beer)

        beer.reload
        VCR.use_cassette(cassette) { webhook.process }

        expect { account.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  def attributes_should_be_equal(beer, attrs)
    beer.name.should                eq(attrs['name'])
    beer.description.should         eq(attrs['description'])
    beer.abv.should                 eq(attrs['abv'].to_f)
    beer.ibu.should                 eq(attrs['ibu'].to_f)
    beer.original_gravity.should    eq(attrs['originalGravity'].to_f)
    beer.should_not be_organic
    beer.serving_temperature.should eq(attrs['servingTemperatureDisplay'])
    beer.availability.should        eq(attrs['available']['name'])
    beer.glassware.should           eq(attrs['glass']['name'])

    beer.created_at.should          eq(Time.zone.parse(attrs['createDate']))
    beer.updated_at.should          eq(Time.zone.parse(attrs['updateDate']))

    beer.image_id.should eq(attrs['labels']['icon'].match(/upload_(\w+)-icon/)[1])
  end
end
