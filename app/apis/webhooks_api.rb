require 'app/workers/webhook_worker'

class WebhooksAPI < BaseAPI
  before :validate_nonce!

  # Rather than route_param here, we define each endpoint so that New Relic
  # treats them as separate endpoints for better tracking.
  %w[beer brewery location guild event].each do |type|
    post type do
      WebhookWorker.perform_async(params.merge(type: type))

      head :accepted
    end
  end

  helper do
    def validate_nonce!
      secret = "#{ENV['BREWERY_DB_API_KEY']}#{params[:nonce]}"
      secret = Digest::SHA1.hexdigest(secret)

      unless params[:key] == secret
        error! :unauthorized, 'Nonce/key pair mismatch.'
      end
    end
  end
end
