require 'spec_helper'
require 'lib/brewery_db/webhooks/shared_examples/social_accounts'
require 'brewery_db/webhooks/guild'

describe BreweryDB::Webhooks::Guild do
  let(:model_id)  { 'cJio9R' }
  let(:cassette) { 'guild' }
  let(:yaml) { YAML.load_file("spec/support/vcr_cassettes/#{cassette}.yml") }
  let(:response) { JSON.parse(yaml['http_interactions'].first['response']['body']['string'])['data'] }
  let(:brewery_response) { JSON.parse(yaml['http_interactions'].second['response']['body']['string'])['data'] }

  it_behaves_like 'a webhook that updates social accounts'

  context '#insert' do
    let(:webhook) { BreweryDB::Webhooks::Guild.new(id: model_id, action: 'insert') }

    context 'before we have breweries' do
      it 'raises an OrderingError' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhooks::OrderingError)
        end
      end
    end

    context 'when have breweries' do
      let(:guild) { ::Guild.find_by(brewerydb_id: model_id) }

      before do
        brewery_response.map { |b| Factory(:brewery, brewerydb_id: b['id']) }
        VCR.use_cassette(cassette) { webhook.process }
      end

      it 'assigns attributes correctly' do
        expect_equal_attributes(guild, response)
      end

      it 'assigns breweries' do
        expect(guild.breweries.count).to eq(brewery_response.count)
      end

      it 'assigns social media accounts' do
        expect(guild.social_media_accounts.count).to eq(response['socialAccounts'].count)
      end
    end
  end

  context 'with an existing guild' do
    let!(:guild)  { Factory(:guild, brewerydb_id: model_id) }

    context '#edit' do
      let(:webhook) { BreweryDB::Webhooks::Guild.new(id: model_id, action: 'edit') }

      before { VCR.use_cassette(cassette) { webhook.process } }

      it 'reassigns attributes correctly' do
        expect_equal_attributes(guild.reload, response)
      end
    end

    context '#brewery_insert' do
      let(:webhook) { BreweryDB::Webhooks::Guild.new(id: model_id, action: 'edit', sub_action: 'brewery_insert') }

      it 'raises an OrderingError if we do not have the breweries yet' do
        VCR.use_cassette(cassette) do
          expect { webhook.process }.to raise_error(BreweryDB::Webhooks::OrderingError)
        end
      end

      it 'assigns breweries if we have them' do
        brewery_response.each { |b| Factory(:brewery, brewerydb_id: b['id']) }
        VCR.use_cassette(cassette) { webhook.process }

        expect(guild.breweries.count).to eq(brewery_response.count)
      end
    end

    context '#brewery_delete' do
      let(:webhook) { BreweryDB::Webhooks::Guild.new(id: model_id, action: 'edit', sub_action: 'brewery_delete') }

      it 'removes breweries from an association' do
        brewery   = Factory(:brewery)
        breweries = brewery_response.map { |b| Factory(:brewery, brewerydb_id: b['id']) }
        breweries << brewery
        guild.breweries = breweries

        VCR.use_cassette(cassette) { webhook.process }
        guild.reload

        expect(guild.breweries.count).to eq(brewery_response.count)
        expect(guild.breweries).not_to include(brewery)
      end
    end

    context '#brewery_edit' do
      let(:webhook) { BreweryDB::Webhooks::Guild.new(id: model_id, action: 'edit', sub_action: 'brewery_edit') }

      it 'acts as a noop, returning true' do
        expect(webhook.process).to be_true
      end
    end
  end

  def expect_equal_attributes(guild, attrs)
    expect(guild.name).to        eq(attrs['name'])
    expect(guild.established).to eq(attrs['established'].to_i)
    expect(guild.description).to eq(attrs['description'])
    expect(guild.website).to     eq(attrs['website'])

    expect(guild.created_at).to  eq(Time.zone.parse(attrs['createDate']))
    expect(guild.updated_at).to  eq(Time.zone.parse(attrs['updateDate']))
  end
end
