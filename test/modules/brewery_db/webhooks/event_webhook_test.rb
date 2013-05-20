require 'test_helper'

class EventWebhookTest < ActiveSupport::TestCase
  context '#insert' do
    before :each do
      @json       = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'event.json'))
      @attributes = JSON.parse(@json)['data']
      stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: @json)

      @webhook = BreweryDB::Webhooks::Event.new({
        id: @attributes['id'],
        action: 'insert'
      })

      @webhook.stubs(:brewery_insert).returns(true)
      @webhook.stubs(:beer_insert).returns(true)
      @webhook.stubs(:socialaccount_insert).returns(true)
    end

    it 'must create an event' do
      @webhook.process
      Event.count.must_equal 1
    end

    it 'must correctly assign attributes to the event' do
      @webhook.process
      @event = Event.find_by(brewerydb_id: @attributes['id'])
      assert_attributes_equal @event, @attributes
    end

    it 'must assign breweries' do
      @webhook.expects(:brewery_insert).returns(true)
      @webhook.process
    end

    it 'must assign beers' do
      @webhook.expects(:beer_insert).returns(true)
      @webhook.process
    end

    it 'must create social accounts' do
      @webhook.expects(:socialaccount_insert).returns(true)
      @webhook.process
    end
  end

  context '#edit' do
    context 'with no sub_action' do
      it 'must update an event' do
        json       = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'event.json'))
        attributes = JSON.parse(json)['data']
        event      = Factory(:event)
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Event.new({
          id: event.brewerydb_id,
          action: 'edit'
        })

        webhook.stubs(:brewery_insert).returns(true)
        webhook.stubs(:beer_insert).returns(true)
        webhook.stubs(:socialaccount_insert).returns(true)

        webhook.process
        event.reload

        assert_attributes_equal(event, attributes)
      end
    end

    context 'with a sub_action of brewery-insert' do
      it "must update the event's brewery collection" do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'breweries.json'))
        attributes = JSON.parse(json)['data']
        brewery = Factory(:brewery, brewerydb_id: attributes.first['id'])
        event = Factory(:event)
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Event.new({
          id: event.brewerydb_id,
          action: 'edit',
          sub_action: 'brewery_insert'
        })

        webhook.process
        event.reload
        event.breweries.must_include brewery
      end
    end

    context 'with a sub_action of brewery-delete' do
      it 'must call brewery-insert' do
        webhook = BreweryDB::Webhooks::Event.new({})
        webhook.method(:brewery_delete).must_equal webhook.method(:brewery_insert)
      end
    end

    context 'with a sub_action of brewery-edit' do
      it 'must do nothing' do
        webhook = BreweryDB::Webhooks::Event.new({})
        webhook.send(:brewery_edit).must_equal true
      end
    end

    context 'with a sub_action of beer-insert' do
      it "must update the event's beer collection" do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'beers.json'))
        attributes = JSON.parse(json)['data']
        event = Factory(:event)
        beer = Factory(:beer, brewerydb_id: attributes.first['id'])
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Event.new({
          id: event.brewerydb_id,
          action: 'edit',
          sub_action: 'beer_insert'
        })

        webhook.process
        event.reload
        event.beers.must_include beer
      end
    end

    context 'with a sub_action of beer-edit' do
      it 'must do nothing' do
        webhook = BreweryDB::Webhooks::Event.new({})
        webhook.send(:beer_edit).must_equal true
      end
    end

    context 'with a sub_action of beer-delete' do
      it 'must call beer-insert' do
        webhook = BreweryDB::Webhooks::Event.new({})
        webhook.method(:beer_delete).must_equal webhook.method(:beer_insert)
      end
    end

    context 'with a sub_action of socialaccount-insert' do
      it 'must create a social_media_account' do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'social_accounts.json'))
        attributes = JSON.parse(json)['data']
        event = Factory(:event)
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Event.new({
          id: event.brewerydb_id,
          action: 'edit',
          sub_action: 'socialaccount_insert'
        })

        webhook.process
        event.reload

        event.social_media_accounts.count.must_equal 1
        account = event.social_media_accounts.first
        account.handle.must_equal attributes.first['handle']
        account.website.must_equal attributes.first['socialMedia']['name']
      end
    end

    context 'with a sub_action of socialaccount-edit' do
      it 'must call socialaccount-insert' do
        webhook = BreweryDB::Webhooks::Event.new({})
        webhook.method(:socialaccount_edit).must_equal webhook.method(:socialaccount_insert)
      end
    end

    context 'with a sub_action of socialaccount-delete' do
      it 'must destroy an existing social_media_account if no longer fetched' do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'social_accounts.json'))
        attributes = JSON.parse(json)['data']
        event = Factory(:event)
        social_account = Factory(:social_media_account, socialable: event, website: 'None')
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Event.new({
          id: event.brewerydb_id,
          action: 'edit',
          sub_action: 'socialaccount_delete'
        })

        webhook.process
        lambda { social_account.reload }.must_raise(ActiveRecord::RecordNotFound)
      end
    end
  end

  context '#delete' do
    it 'must delete the event with the passed brewerydb_id' do
      webhook = BreweryDB::Webhooks::Event.new({
        id: 'hELlo',
        action: 'delete'
      })

      event = Factory(:event, brewerydb_id: 'hELlo')
      webhook.process

      lambda { event.reload }.must_raise(ActiveRecord::RecordNotFound)
    end
  end

  private
    def assert_attributes_equal(event, attributes)
      event.name.must_equal        attributes['name']
      event.year.must_equal        attributes['year'].to_i
      event.description.must_equal attributes['description']
      event.category.must_equal    attributes['typeDisplay']
      event.start_date.must_equal  Date.parse(attributes['startDate'])
      event.end_date.must_equal    Date.parse(attributes['endDate'])
      event.hours.must_equal       attributes['time']
      event.price.must_equal       attributes['price']
      event.venue.must_equal       attributes['venueName']
      event.street.must_equal      attributes['streetAddress']
      event.street2.must_equal     attributes['extendedAddress']
      event.city.must_equal        attributes['locality']
      event.region.must_equal      attributes['region']
      event.postal_code.must_equal attributes['postalCode']
      event.country.must_equal     attributes['countryIsoCode']
      event.latitude.must_equal    attributes['latitude']
      event.longitude.must_equal   attributes['longitude']
      event.website.must_equal     attributes['website']
      event.phone.must_equal       attributes['phone']

      event.created_at.must_equal  Time.zone.parse(attributes['createDate'])
      event.updated_at.must_equal  Time.zone.parse(attributes['updateDate'])

      event.image_id.must_equal    attributes['images']['icon'].match(/upload_(\w+)-icon/)[1]
    end
end
