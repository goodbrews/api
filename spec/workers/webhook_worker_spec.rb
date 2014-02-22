require 'spec_helper'
require 'app/workers/webhook_worker'

describe WebhookWorker do
  %w[beer brewery event guild location].each do |klass|
    it "creates a #{klass} webhook given a set of params" do
      params = {
        'type' => klass,
        'action' => 'edit',
        'attributeId' => 'fake',
        'subAction' => 'socialAccountInsert'
      }

      options = {
        action: params['action'],
        id: params['attributeId'],
        sub_action: params['subAction'].underscore
      }

      mock  = double("BreweryDB::Webhooks::#{klass.classify}", process: true)
      klass = BreweryDB::Webhooks::const_get(klass.classify)
      expect(klass).to receive(:new).with(options).and_return(mock)

      WebhookWorker.new.perform(params)
    end
  end
end
