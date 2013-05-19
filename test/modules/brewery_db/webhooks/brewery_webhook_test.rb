require 'test_helper'

class BreweryWebhookTest < ActiveSupport::TestCase
  context '#insert' do
    before :each do
      @json       = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'brewery.json'))
      @attributes = JSON.parse(@json)['data']
      @guild      = Factory(:guild, brewerydb_id: @attributes['guilds'].first['id'])
      stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: @json)

      @webhook = BreweryDB::Webhooks::Brewery.new({
        id: @attributes['id'],
        action: 'insert'
      })

      @webhook.process
      @brewery = Brewery.find_by(brewerydb_id: @attributes['id'])
    end

    it 'must create a brewery' do
      Brewery.count.must_equal 1
    end

    it 'must correctly assign attributes to the brewery' do
      assert_attributes_equal @brewery, @attributes
    end

    it 'must assign guilds' do
      @brewery.guilds.count.must_equal 1
      @brewery.guilds.first.must_equal @guild
    end

    it 'must assign alternate names' do
      @brewery.alternate_names.count.must_equal 1
      @brewery.alternate_names.first.must_equal @attributes['alternateNames'].first['altName']
    end

    it 'must create social accounts' do
      @brewery.social_media_accounts.count.must_equal 1
      @brewery.social_media_accounts.first.website.must_equal "Untappd"
    end
  end

  context '#edit' do
    context 'with no sub_action' do
      it 'must update a brewery' do
        json       = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'brewery.json'))
        attributes = JSON.parse(json)['data']
        brewery    = Factory(:brewery, brewerydb_id: attributes['id'])
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Brewery.new({
          id: brewery.brewerydb_id,
          action: 'edit'
        })

        webhook.process
        brewery.reload

        assert_attributes_equal(brewery, attributes)
      end
    end

    context 'with a sub_action of alternatename-insert' do
      it "must update a brewery's alternate names" do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'alternate_names.json'))
        attributes = JSON.parse(json)['data']
        brewery = Factory(:brewery)
        alternate_name = attributes.first['altName']
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Brewery.new({
          id: brewery.brewerydb_id,
          action: 'edit',
          sub_action: 'alternatename_insert'
        })

        webhook.process
        brewery.reload
        brewery.alternate_names.must_include alternate_name
      end
    end

    context 'with a sub_action of alternatename-delete' do
      it 'must call alternatename-insert' do
        webhook = BreweryDB::Webhooks::Brewery.new({})
        webhook.method(:alternatename_delete).must_equal webhook.method(:alternatename_insert)
      end
    end

    context 'with a sub_action of beer-insert' do
      it "must update the brewery's beer collection" do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'beers.json'))
        attributes = JSON.parse(json)['data']
        brewery = Factory(:brewery)
        beer = Factory(:beer, brewerydb_id: attributes.first['id'])
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Brewery.new({
          id: brewery.brewerydb_id,
          action: 'edit',
          sub_action: 'beer_insert'
        })

        webhook.process
        brewery.reload
        brewery.beers.must_include beer
      end
    end

    context 'with a sub_action of beer-edit' do
      it 'must do nothing' do
        webhook = BreweryDB::Webhooks::Brewery.new({})
        webhook.send(:beer_edit).must_equal true
      end
    end

    context 'with a sub_action of beer-delete' do
      it 'must call beer-insert' do
        webhook = BreweryDB::Webhooks::Brewery.new({})
        webhook.method(:beer_delete).must_equal webhook.method(:beer_insert)
      end
    end

    context 'with a sub_action of event-insert' do
      it "must update the brewery's event collection" do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'events.json'))
        attributes = JSON.parse(json)['data']
        brewery = Factory(:brewery)
        event = Factory(:event, brewerydb_id: attributes.first['id'])
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Brewery.new({
          id: brewery.brewerydb_id,
          action: 'edit',
          sub_action: 'event_insert'
        })

        webhook.process
        brewery.reload
        brewery.events.must_include event
      end
    end

    context 'with a sub_action of event-delete' do
      it 'must call event-insert' do
        webhook = BreweryDB::Webhooks::Brewery.new({})
        webhook.method(:event_delete).must_equal webhook.method(:event_insert)
      end
    end

    context 'with a sub_action of event-edit' do
      it 'must do nothing' do
        webhook = BreweryDB::Webhooks::Brewery.new({})
        webhook.send(:event_edit).must_equal true
      end
    end

    context 'with a sub_action of guild-insert' do
      it "must update the brewery's event collection" do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'guilds.json'))
        attributes = JSON.parse(json)['data']
        brewery = Factory(:brewery)
        guild = Factory(:guild, brewerydb_id: attributes.first['id'])
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Brewery.new({
          id: brewery.brewerydb_id,
          action: 'edit',
          sub_action: 'guild_insert'
        })

        webhook.process
        brewery.reload
        brewery.guilds.must_include guild
      end
    end

    context 'with a sub_action of guild-edit' do
      it 'must do nothing' do
        webhook = BreweryDB::Webhooks::Brewery.new({})
        webhook.send(:guild_edit).must_equal true
      end
    end

    context 'with a sub_action of guild-delete' do
      it 'must call guild-insert' do
        webhook = BreweryDB::Webhooks::Brewery.new({})
        webhook.method(:guild_delete).must_equal webhook.method(:guild_insert)
      end
    end

    context 'with a sub_action of socialaccount-insert' do
      it 'must create a social_media_account' do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'social_accounts.json'))
        attributes = JSON.parse(json)['data']
        brewery = Factory(:brewery)
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Brewery.new({
          id: brewery.brewerydb_id,
          action: 'edit',
          sub_action: 'socialaccount_insert'
        })

        webhook.process
        brewery.reload

        brewery.social_media_accounts.count.must_equal 1
        account = brewery.social_media_accounts.first
        account.handle.must_equal attributes.first['handle']
        account.website.must_equal attributes.first['socialMedia']['name']
      end
    end

    context 'with a sub_action of socialaccount-delete' do
      it 'must destroy an existing social_media_account if no longer fetched' do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'social_accounts.json'))
        attributes = JSON.parse(json)['data']
        brewery = Factory(:brewery)
        social_account = Factory(:social_media_account, socialable: brewery, website: 'None')
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Brewery.new({
          id: brewery.brewerydb_id,
          action: 'edit',
          sub_action: 'socialaccount_delete'
        })

        webhook.process
        lambda { social_account.reload }.must_raise(ActiveRecord::RecordNotFound)
      end
    end

    context 'with a sub_action of socialaccount-edit' do
      it 'must call socialaccount-insert' do
        webhook = BreweryDB::Webhooks::Brewery.new({})
        webhook.method(:socialaccount_edit).must_equal webhook.method(:socialaccount_insert)
      end
    end

    %w[insert delete edit].each do |action|
      context "with a sub_action of location-#{action}" do
        it 'must do nothing' do
          webhook = BreweryDB::Webhooks::Brewery.new({})
          webhook.send("location_#{action}").must_equal true
        end
      end
    end
  end

  context '#delete' do
    it 'should destroy the brewery' do
      webhook = BreweryDB::Webhooks::Brewery.new({
        id: 'hELlo',
        action: 'delete'
      })

      brewery = Factory(:brewery, brewerydb_id: 'hELlo')
      webhook.process

      lambda { brewery.reload }.must_raise(ActiveRecord::RecordNotFound)
    end
  end

  private
    def assert_attributes_equal(brewery, attributes)
      brewery.name.must_equal        attributes['name']
      brewery.website.must_equal     attributes['website']
      brewery.description.must_equal attributes['description']
      brewery.established.must_equal attributes['established']
      brewery.must_be :organic?

      brewery.created_at.must_equal  Time.zone.parse(attributes['createDate'])

      brewery.image_id.must_equal    attributes['images']['icon'].match(/upload_(\w+)-icon/)[1]
    end
end
