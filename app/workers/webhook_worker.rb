require 'brewery_db/webhook/beer'
require 'brewery_db/webhook/brewery'
require 'brewery_db/webhook/event'
require 'brewery_db/webhook/guild'
require 'brewery_db/webhook/location'

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

    webhook_klass = BreweryDB::Webhook::const_get(type.classify)
    ::NewRelic::Agent.add_custom_parameters(options.merge(type: type))

    webhook_klass.new(options).process
  end
end
