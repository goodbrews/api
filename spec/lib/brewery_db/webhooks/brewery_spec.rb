require 'spec_helper'
require 'lib/brewery_db/webhooks/shared_examples/events'
require 'lib/brewery_db/webhooks/shared_examples/social_accounts'
require 'brewery_db/webhooks/brewery'

describe BreweryDB::Webhooks::Brewery do
  let(:model_id) { 'g0jHqt' }
  let(:response) do
    yaml = YAML.load_file("spec/support/vcr_cassettes/#{cassette}.yml")
    JSON.parse(yaml['http_interactions'].first['response']['body']['string'])['data']
  end

  it_behaves_like 'a webhook that updates events'
  it_behaves_like 'a webhook that updates social accounts'

  context '#insert' do
    let(:cassette) { 'brewery_with_associations' }
    let(:webhook) { BreweryDB::Webhooks::Brewery.new(id: model_id, action: 'insert') }

    context 'before we have guilds' do
      it 'raises an OrderingError' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhooks::OrderingError)
        end
      end
    end

    context 'when we have guilds' do
      let(:brewery) { Brewery.find_by(brewerydb_id: model_id) }
      before do
        response['guilds'].map { |g| Factory(:guild, brewerydb_id: g['id']) }
        VCR.use_cassette(cassette) { webhook.process }
      end

      it 'creates a brewery' do
        expect(brewery).not_to be_nil
      end

      it 'assigns attributes correctly' do
        expect_equal_attributes(brewery, response)
      end

      it 'assigns guilds' do
        expect(brewery.guilds.count).to eq(response['guilds'].count)
      end

      it 'creates social media accounts' do
        expect(brewery.social_media_accounts.count).to eq(response['socialAccounts'].count)
      end

      it 'parses and assigns alternate names' do
        expect(brewery.alternate_names.presence).to eq(response['alternateNames'].presence)
      end
    end
  end

  context 'with an existing brewery' do
    let!(:brewery)  { Factory(:brewery, brewerydb_id: model_id) }

    context '#edit' do
      let(:cassette) { 'brewery_with_associations' }
      let(:webhook) { BreweryDB::Webhooks::Brewery.new(id: model_id, action: 'edit') }

      before do
        response['guilds'].map { |g| Factory(:guild, brewerydb_id: g['id']) }
        VCR.use_cassette(cassette) { webhook.process }
      end

      it 'reassigns attributes correctly' do
        expect_equal_attributes(brewery.reload, response)
      end
    end

    context '#guild_insert' do
      let(:cassette) { 'brewery_guilds' }
      let(:webhook) { BreweryDB::Webhooks::Brewery.new(id: model_id, action: 'edit', sub_action: 'guild_insert') }

      it 'raises an OrderingError if we do not have the guilds yet' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhooks::OrderingError)
        end
      end

      it 'assigns guilds if we have them' do
        response.each { |g| Factory(:guild, brewerydb_id: g['id']) }
        VCR.use_cassette(cassette) { webhook.process }

        expect(brewery.guilds.count).to eq(response.count)
      end
    end

    context '#guild_delete' do
      let(:cassette) { 'brewery_guilds' }
      let(:webhook) { BreweryDB::Webhooks::Brewery.new(id: model_id, action: 'edit', sub_action: 'guild_delete') }

      it 'removes guilds from an association' do
        guild = Factory(:guild)
        guilds = response.map { |g| Factory(:guild, brewerydb_id: g['id']) }
        guilds << guild
        brewery.guilds = guilds

        VCR.use_cassette(cassette) { webhook.process }
        brewery.reload

        expect(brewery.guilds.count).to eq(response.count)
        expect(brewery.guilds).not_to include(guild)
      end
    end

    context '#guild_edit' do
      let(:webhook) { BreweryDB::Webhooks::Brewery.new(id: model_id, action: 'edit', sub_action: 'guild_edit') }

      it 'acts as a noop, returning true' do
        expect(webhook.process).to be_true
      end
    end

    context '#beer_insert' do
      let(:cassette) { 'brewery_beers' }
      let(:webhook) { BreweryDB::Webhooks::Brewery.new(id: model_id, action: 'edit', sub_action: 'beer_insert') }

      it 'raises an OrderingError if we do not have the beers yet' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhooks::OrderingError)
        end
      end

      it 'assigns beers if we have them' do
        response.each { |b| Factory(:beer, brewerydb_id: b['id']) }
        VCR.use_cassette(cassette) { webhook.process }

        expect(brewery.beers.count).to eq(response.count)
      end
    end

    context '#beer_delete' do
      let(:cassette) { 'brewery_beers' }
      let(:webhook) { BreweryDB::Webhooks::Brewery.new(id: model_id, action: 'edit', sub_action: 'beer_delete') }

      it 'removes beers from an association' do
        beer = Factory(:beer)
        beers = response.map { |b| Factory(:beer, brewerydb_id: b['id']) }
        beers << beer
        brewery.beers = beers

        VCR.use_cassette(cassette) { webhook.process }
        brewery.reload

        expect(brewery.beers.count).to eq(response.count)
        expect(brewery.beers).not_to include(beer)
      end
    end

    context '#beer_edit' do
      let(:webhook) { BreweryDB::Webhooks::Brewery.new(id: model_id, action: 'edit', sub_action: 'beer_edit') }

      it 'acts as a noop, returning true' do
        expect(webhook.process).to be_true
      end
    end

    %w[insert delete edit].each do |action|
      let(:webhook) { BreweryDB::Webhooks::Brewery.new(id: model_id, action: 'edit', sub_action: "location_#{action}") }

      context "#location_#{action}" do
        it 'should be a noop, returning true' do
          expect(webhook.process).to be_true
        end
      end
    end
  end

  def expect_equal_attributes(brewery, attrs)
    expect(brewery.name).to                eq(attrs['name'])
    expect(brewery.website).to             eq(attrs['website'])
    expect(brewery.description).to         eq(attrs['description'])
    expect(brewery.established).to         eq(attrs['established'].to_i)
    expect(brewery).not_to be_organic

    expect(brewery.created_at).to          eq(Time.zone.parse(attrs['createDate']))
    expect(brewery.updated_at).to          eq(Time.zone.parse(attrs['updateDate']))

    expect(brewery.image_id).to eq(attrs['images']['icon'].match(/upload_(\w+)-icon/)[1])
  end
end
