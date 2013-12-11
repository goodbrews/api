require 'brewery_db/webhooks/beer'
require 'brewery_db/webhooks/brewery'
require 'brewery_db/webhooks/event'
require 'brewery_db/webhooks/guild'
require 'brewery_db/webhooks/location'

class WebhookWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'webhooks'

  def perform(params)
    type = params.delete(:type)

    options = {
      action:     params[:action],
      id:         params[:attributeId],
      sub_action: params[:subAction] == 'none' ? nil : params[:subAction].underscore
    }

    webhook_klass = BreweryDB::Webhooks::const_get(type.classify)
    ::NewRelic::Agent.add_custom_parameters(options.merge(type: type))

    webhook_klass.new(options).process
  end
end
