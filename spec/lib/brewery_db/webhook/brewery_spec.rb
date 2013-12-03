require 'spec_helper'
require 'brewery_db/webhook/brewery'

describe BreweryDB::Webhook::Brewery do
  let(:brewery_id) { 'g0jHqt' }
  let(:response) do
    yaml = YAML.load_file("spec/support/vcr_cassettes/#{cassette}.yml")
    JSON.parse(yaml['http_interactions'].first['response']['body']['string'])['data']
  end

  context '#insert' do
    let(:cassette) { 'brewery_with_associations' }
    let(:webhook) { BreweryDB::Webhook::Brewery.new(id: brewery_id, action: 'insert') }

    context 'before we have guilds' do
      it 'raises an OrderingError' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhook::Brewery::OrderingError)
        end
      end
    end

    context 'when we have guilds' do
      let(:brewery) { Brewery.find_by(brewerydb_id: brewery_id) }
      before do
        response['guilds'].map { |g| Factory(:guild, brewerydb_id: g['id']) }
        VCR.use_cassette(cassette) { webhook.process }
      end

      it 'creates a brewery' do
        brewery.should_not be_nil
      end

      it 'assigns attributes correctly' do
        attributes_should_be_equal(brewery, response)
      end

      it 'assigns guilds' do
        brewery.guilds.count.should eq(response['guilds'].count)
      end

      it 'creates social media accounts' do
        brewery.social_media_accounts.count.should eq(response['socialAccounts'].count)
      end

      it 'parses and assigns alternate names' do
        brewery.alternate_names.presence.should eq(response['alternateNames'].presence)
      end
    end
  end

  context 'with an existing brewery' do
    let!(:brewery)  { Factory(:brewery, brewerydb_id: brewery_id) }

    context '#edit' do
      let(:cassette) { 'brewery_with_associations' }
      let(:webhook) { BreweryDB::Webhook::Brewery.new(id: brewery_id, action: 'edit') }

      before do
        response['guilds'].map { |g| Factory(:guild, brewerydb_id: g['id']) }
        VCR.use_cassette(cassette) { webhook.process }
      end

      it 'reassigns attributes correctly' do
        attributes_should_be_equal(brewery.reload, response)
      end
    end

    context '#guild_insert' do
      let(:cassette) { 'brewery_guilds' }
      let(:webhook) { BreweryDB::Webhook::Brewery.new(id: brewery_id, action: 'edit', sub_action: 'guild_insert') }

      it 'raises an OrderingError if we do not have the guilds yet' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhook::Brewery::OrderingError)
        end
      end

      it 'assigns guilds if we have them' do
        response.each { |g| Factory(:guild, brewerydb_id: g['id']) }
        VCR.use_cassette(cassette) { webhook.process }

        brewery.guilds.count.should eq(response.count)
      end
    end

    context '#guild_delete' do
      let(:cassette) { 'brewery_guilds' }
      let(:webhook) { BreweryDB::Webhook::Brewery.new(id: brewery_id, action: 'edit', sub_action: 'guild_delete') }

      it 'removes guilds from an association' do
        guild = Factory(:guild)
        guilds = response.map { |g| Factory(:guild, brewerydb_id: g['id']) }
        guilds << guild
        brewery.guilds = guilds

        VCR.use_cassette(cassette) { webhook.process }
        brewery.reload

        brewery.guilds.count.should eq(response.count)
        brewery.guilds.should_not include(guild)
      end
    end

    context '#guild_edit' do
      let(:webhook) { BreweryDB::Webhook::Brewery.new(id: brewery_id, action: 'edit', sub_action: 'guild_edit') }

      it 'acts as a noop, returning true' do
        webhook.process.should be_true
      end
    end

    context '#event_insert' do
      let(:cassette) { 'brewery_events' }
      let(:webhook) { BreweryDB::Webhook::Brewery.new(id: brewery_id, action: 'edit', sub_action: 'event_insert') }

      it 'raises an OrderingError if we do not have the events yet' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhook::Brewery::OrderingError)
        end
      end

      it 'assigns events if we have them' do
        response.each { |e| Factory(:event, brewerydb_id: e['eventId']) }
        VCR.use_cassette(cassette) { webhook.process }

        brewery.events.count.should eq(response.count)
      end
    end

    context '#event_delete' do
      let(:cassette) { 'brewery_events' }
      let(:webhook) { BreweryDB::Webhook::Brewery.new(id: brewery_id, action: 'edit', sub_action: 'event_delete') }

      it 'removes events from an association' do
        event = Factory(:event)
        events = response.map { |e| Factory(:event, brewerydb_id: e['eventId']) }
        events << event
        brewery.events = events

        VCR.use_cassette(cassette) { webhook.process }
        brewery.reload

        brewery.events.count.should eq(response.count)
        brewery.events.should_not include(event)
      end
    end

    context '#event_edit' do
      let(:webhook) { BreweryDB::Webhook::Brewery.new(id: brewery_id, action: 'edit', sub_action: 'event_edit') }

      it 'acts as a noop, returning true' do
        webhook.process.should be_true
      end
    end

    context '#socialaccount_insert' do
      let(:cassette) { 'brewery_social_media_accounts' }
      let(:webhook) { BreweryDB::Webhook::Brewery.new(id: brewery_id, action: 'edit', sub_action: 'socialaccount_insert') }

      before { VCR.use_cassette(cassette) { webhook.process } }

      it 'creates and assigns social_media_accounts' do
        brewery.social_media_accounts.count.should eq(response.count)
      end
    end

    context '#socialaccount_delete' do
      let(:cassette) { 'brewery_social_media_accounts' }
      let(:webhook) { BreweryDB::Webhook::Brewery.new(id: brewery_id, action: 'edit', sub_action: 'socialaccount_delete') }

      it 'destroys social_media_accounts' do
        accounts = response.map { |a| Factory(:social_media_account, website: a['name'], socialable: brewery) }
        account = Factory(:social_media_account, website: 'BeerAdvocate', socialable: brewery)

        brewery.reload
        VCR.use_cassette(cassette) { webhook.process }

        expect { account.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    %w[insert delete edit].each do |action|
      let(:webhook) { BreweryDB::Webhook::Brewery.new(id: brewery_id, action: 'edit', sub_action: "location_#{action}") }

      context "#location_#{action}" do
        it 'should be a noop, returning true' do
          webhook.process.should be_true
        end
      end
    end
  end

  def attributes_should_be_equal(brewery, attrs)
    brewery.name.should                eq(attrs['name'])
    brewery.website.should             eq(attrs['website'])
    brewery.description.should         eq(attrs['description'])
    brewery.established.should         eq(attrs['established'].to_i)
    brewery.should_not be_organic

    brewery.created_at.should          eq(Time.zone.parse(attrs['createDate']))
    brewery.updated_at.should          eq(Time.zone.parse(attrs['updateDate']))

    brewery.image_id.should eq(attrs['images']['icon'].match(/upload_(\w+)-icon/)[1])
  end
end