require 'test_helper'

class BeerWebhookTest < ActiveSupport::TestCase
  context '#insert' do
  end

  context '#edit' do
  end

  context '#delete' do
    it 'should delete the beer with the passed brewerydb_id' do
      webhook = BreweryDB::Webhooks::Beer.new({
        id: 'dAvID',
        action: 'delete'
      })

      beer = Factory(:beer, brewerydb_id: 'dAvID')
      webhook.process

      lambda { beer.reload }.must_raise(ActiveRecord::RecordNotFound)
    end
  end
end
