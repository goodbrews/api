require 'test_helper'

class GuildWebhookTest < ActiveSupport::TestCase
  context '#insert' do
    before :each do
      @json       = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'guild.json'))
      @attributes = JSON.parse(@json)['data']
      stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: @json)

      @webhook = BreweryDB::Webhooks::Guild.new({
        id: @attributes['id'],
        action: 'insert'
      })

      # It must assign breweries
      @webhook.expects(:brewery_insert).returns(true)

      # It must assign social accounts
      @webhook.expects(:socialaccount_insert).returns(true)

      @webhook.process
      @guild = Guild.find_by(brewerydb_id: @attributes['id'])
    end

    it 'must create a guild' do
      Guild.count.must_equal 1
    end

    it 'must correctly assign attributes to the guild' do
      assert_attributes_equal @guild, @attributes
    end
  end

  context '#edit' do
    context 'with no sub_action' do
      it 'must update a guild' do
        json        = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'guild.json'))
        attributes  = JSON.parse(json)['data']
        guild       = Factory(:guild, brewerydb_id: attributes['id'])
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Guild.new({
          id: guild.brewerydb_id,
          action: 'edit'
        })

        webhook.expects(:brewery_insert).never
        webhook.expects(:socialaccount_insert).never

        webhook.process
        guild.reload

        assert_attributes_equal guild, attributes
      end
    end

    context 'with a sub_action of brewery-insert' do
      it "must update the guild's brewery collection" do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'breweries.json'))
        attributes = JSON.parse(json)['data']
        brewery = Factory(:brewery, brewerydb_id: attributes.first['id'])
        guild = Factory(:guild)
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Guild.new({
          id: guild.brewerydb_id,
          action: 'edit',
          sub_action: 'brewery_insert'
        })

        webhook.process
        guild.reload
        guild.breweries.must_include brewery
      end
    end

    context 'with a sub_action of brewery-delete' do
      it 'must call brewery-insert' do
        webhook = BreweryDB::Webhooks::Guild.new({})
        webhook.method(:brewery_delete).must_equal webhook.method(:brewery_insert)
      end
    end

    context 'with a sub_action of brewery-edit' do
      it 'must do nothing' do
        webhook = BreweryDB::Webhooks::Guild.new({})
        webhook.send(:brewery_edit).must_equal true
      end
    end

    context 'with a sub_action of socialaccount-insert' do
      it 'must create a social_media_account' do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'social_accounts.json'))
        attributes = JSON.parse(json)['data']
        guild = Factory(:guild)
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Guild.new({
          id: guild.brewerydb_id,
          action: 'edit',
          sub_action: 'socialaccount_insert'
        })

        webhook.process
        guild.reload

        guild.social_media_accounts.count.must_equal 1
        account = guild.social_media_accounts.first
        account.handle.must_equal  attributes.first['handle']
        account.website.must_equal attributes.first['socialMedia']['name']
      end
    end

    context 'with a sub_action of socialaccount-edit' do
      it 'must call socialaccount-insert' do
        webhook = BreweryDB::Webhooks::Guild.new({})
        webhook.method(:socialaccount_edit).must_equal webhook.method(:socialaccount_insert)
      end
    end

    context 'with a sub_action of socialaccount-delete' do
      it 'must destroy an existing social_media_account if no longer fetched' do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'social_accounts.json'))
        attributes = JSON.parse(json)['data']
        guild = Factory(:guild)
        social_account = Factory(:social_media_account, socialable: guild, website: 'None')
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Guild.new({
          id: guild.brewerydb_id,
          action: 'edit',
          sub_action: 'socialaccount_delete'
        })

        webhook.process
        lambda { social_account.reload }.must_raise(ActiveRecord::RecordNotFound)
      end
    end
  end

  context '#delete' do
    it 'must delete the guild with the passed brewerydb_id' do
      webhook = BreweryDB::Webhooks::Guild.new({
        id: 'dAvID',
        action: 'delete'
      })

      guild = Factory(:guild, brewerydb_id: 'dAvID')
      webhook.process

      lambda { guild.reload }.must_raise(ActiveRecord::RecordNotFound)
    end
  end

  private
    def assert_attributes_equal(guild, attributes)
      guild.name.must_equal        attributes['name']
      guild.description.must_equal attributes['description']
      guild.website.must_equal     attributes['website']
      guild.established.must_equal attributes['established'].to_i

      guild.created_at.must_equal  Time.zone.parse(attributes['createDate'])
      guild.updated_at.must_equal  Time.zone.parse(attributes['updateDate'])

      guild.image_id.must_equal attributes['images']['icon'].match(/upload_(\w+)-icon/)[1]
    end
end
