require 'brewery_db/webhooks/beer'
require 'brewery_db/webhooks/brewery'
require 'brewery_db/webhooks/event'
require 'brewery_db/webhooks/guild'
require 'brewery_db/webhooks/location'

class WebhookWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'webhooks'

  def perform(params)
    type = params['type']

    options = {
      action:     params['action'],
      id:         params['attributeId']
    }

    options[:sub_action] = params['sub_action'] unless params['sub_action'] == 'none'

    webhook_klass = BreweryDB::Webhooks::const_get(type.classify)
    ::NewRelic::Agent.add_custom_parameters(options.merge(type: type))

    webhook_klass.new(options).process
  end
end
