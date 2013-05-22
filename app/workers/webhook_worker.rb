class WebhookWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'webhooks'

  def perform(type, options)
    webhook = ::BreweryDB::Webhooks.const_get(type.classify).new(options)
    webhook.process
  end
end
