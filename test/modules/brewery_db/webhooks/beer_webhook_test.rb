require 'test_helper'

class BeerWebhookTest < ActiveSupport::TestCase
  context '#insert' do
    before :each do
      @json       = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'beer.json'))
      @attributes = JSON.parse(@json)['data']
      @style      = Factory(:style, id: @attributes['styleId'])
      @brewery    = Factory(:brewery, brewerydb_id: @attributes['breweries'][0]['id'])
      stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: @json)

      @webhook = BreweryDB::Webhooks::Beer.new({
        id: @attributes['id'],
        action: 'insert'
      })

      @webhook.process
      @beer = Beer.find_by(brewerydb_id: @attributes['id'])
    end

    it 'must create a beer' do
      Beer.count.must_equal 1
    end

    it 'must correctly assign attributes to the beer' do
      assert_attributes_equal @beer, @attributes
    end

    it 'must assign a style' do
      style = Style.find(@attributes['styleId'])
      @beer.style.must_equal style
    end

    it 'must assign breweries' do
      breweries = Brewery.where(brewerydb_id: @attributes['breweries'].map { |b| b['id'] })

      @beer.breweries.count.must_equal 1
      @beer.breweries.first.must_equal @brewery
    end

    it 'must create social accounts' do
      @beer.social_media_accounts.count.must_equal 1
      @beer.social_media_accounts.first.website.must_equal "Untappd"
    end

    it 'must assign ingredients' do
      ingredients = @beer.ingredients

      ingredients.count.must_equal 2
      ingredients.map(&:category).must_include 'Hops'
      ingredients.map(&:category).must_include 'Malts, Grains & Fermentables'
    end
  end

  context '#edit' do
    context 'with no sub_action' do
      it 'must update a beer' do
        json       = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'beer.json'))
        attributes = JSON.parse(json)['data']
        style      = Factory(:style, id: attributes['styleId'])
        brewery    = Factory(:brewery, brewerydb_id: attributes['breweries'][0]['id'])
        beer       = Factory(:beer, brewerydb_id: attributes['id'])
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Beer.new({
          id: attributes['id'],
          action: 'edit'
        })

        webhook.process
        beer.reload

        assert_attributes_equal(beer, attributes)
      end
    end

    context 'with a sub_action of brewery-insert' do
      it "must update the beer's brewery collection" do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'breweries.json'))
        attributes = JSON.parse(json)['data']
        brewery = Factory(:brewery, brewerydb_id: attributes.first['id'])
        beer = Factory(:beer)
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Beer.new({
          id: beer.brewerydb_id,
          action: 'edit',
          sub_action: 'brewery_insert'
        })

        webhook.process
        beer.reload
        beer.breweries.must_include brewery
      end
    end

    context 'with a sub_action of brewery-delete' do
      it 'must call brewery-insert' do
        webhook = BreweryDB::Webhooks::Beer.new({})
        webhook.method(:brewery_delete).must_equal webhook.method(:brewery_insert)
      end
    end

    context 'with a sub_action of brewery-edit' do
      it 'must do nothing' do
        webhook = BreweryDB::Webhooks::Beer.new({})
        webhook.send(:brewery_edit).must_equal true
      end
    end

    context 'with a sub_action of event-insert' do
      it "must update the beer's event collection" do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'events.json'))
        attributes = JSON.parse(json)['data']
        beer = Factory(:beer)
        event = Factory(:event, brewerydb_id: attributes.first['id'])
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Beer.new({
          id: beer.brewerydb_id,
          action: 'edit',
          sub_action: 'event_insert'
        })

        webhook.process
        beer.reload
        beer.events.must_include event
      end
    end

    context 'with a sub_action of event-delete' do
      it 'must call event-insert' do
        webhook = BreweryDB::Webhooks::Beer.new({})
        webhook.method(:event_delete).must_equal webhook.method(:event_insert)
      end
    end

    context 'with a sub_action of event-edit' do
      it 'must do nothing' do
        webhook = BreweryDB::Webhooks::Beer.new({})
        webhook.send(:event_edit).must_equal true
      end
    end

    context 'with a sub_action of ingredient-insert' do
      it "must update the beer's ingredient collection" do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'ingredients.json'))
        attributes = JSON.parse(json)['data']
        beer = Factory(:beer)
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Beer.new({
          id: beer.brewerydb_id,
          action: 'edit',
          sub_action: 'ingredient_insert'
        })

        webhook.process
        beer.reload
        ingredients = beer.ingredients

        ingredients.count.must_equal 2
        ingredients.must_include ::Ingredient.find(attributes.first['id'])
        ingredients.must_include ::Ingredient.find(attributes.last['id'])
      end
    end

    context 'with a sub_action of ingredient-delete' do
      it 'must call ingredient_insert' do
        webhook = BreweryDB::Webhooks::Beer.new({})
        webhook.method(:ingredient_delete).must_equal webhook.method(:ingredient_insert)
      end
    end

    context 'with a sub_action of socialaccount-insert' do
      it 'must create a social_media_account' do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'social_accounts.json'))
        attributes = JSON.parse(json)['data']
        beer = Factory(:beer)
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Beer.new({
          id: beer.brewerydb_id,
          action: 'edit',
          sub_action: 'socialaccount_insert'
        })

        webhook.process
        beer.reload

        beer.social_media_accounts.count.must_equal 1
        account = beer.social_media_accounts.first
        account.handle.must_equal attributes.first['handle']
        account.website.must_equal attributes.first['socialMedia']['name']
      end
    end

    context 'with a sub_action of socialaccount-edit' do
      it 'must call socialaccount-insert' do
        webhook = BreweryDB::Webhooks::Beer.new({})
        webhook.method(:socialaccount_edit).must_equal webhook.method(:socialaccount_insert)
      end
    end

    context 'with a sub_action of socialaccount-delete' do
      it 'must destroy an existing social_media_account if no longer fetched' do
        json = File.read(Rails.root.join('test', 'modules', 'brewery_db', 'fixtures', 'social_accounts.json'))
        attributes = JSON.parse(json)['data']
        beer = Factory(:beer)
        social_account = Factory(:social_media_account, socialable: beer, website: 'None')
        stub_request(:get, /.*api.brewerydb.com.*/).to_return(body: json)

        webhook = BreweryDB::Webhooks::Beer.new({
          id: beer.brewerydb_id,
          action: 'edit',
          sub_action: 'socialaccount_delete'
        })

        webhook.process
        lambda { social_account.reload }.must_raise(ActiveRecord::RecordNotFound)
      end
    end
  end

  context '#delete' do
    it 'must delete the beer with the passed brewerydb_id' do
      webhook = BreweryDB::Webhooks::Beer.new({
        id: 'dAvID',
        action: 'delete'
      })

      beer = Factory(:beer, brewerydb_id: 'dAvID')
      webhook.process

      lambda { beer.reload }.must_raise(ActiveRecord::RecordNotFound)
    end
  end

  private
    def assert_attributes_equal(beer, attributes)
      beer.name.must_equal                attributes['name']
      beer.description.must_equal         attributes['description']
      beer.abv.must_equal                 attributes['abv'].to_f
      beer.ibu.must_equal                 attributes['ibu'].to_f
      beer.original_gravity.must_equal    attributes['originalGravity'].to_f
      beer.must_be :organic?
      beer.serving_temperature.must_equal attributes['servingTemperatureDisplay']
      beer.availability.must_equal        attributes['available']['name']
      beer.glassware.must_equal           attributes['glass']['name']

      beer.created_at.must_equal          Time.zone.parse(attributes['createDate'])
      beer.updated_at.must_equal          Time.zone.parse(attributes['updateDate'])

      beer.image_id.must_equal attributes['labels']['icon'].match(/upload_(\w+)-icon/)[1]
    end
end
