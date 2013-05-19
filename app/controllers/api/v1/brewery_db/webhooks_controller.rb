class Api::V1::BreweryDB::WebhooksController < ApplicationController
  before_filter :verify_nonce!

  # POST /brewery_db/webhooks/{beer,brewery,location,guild,event}
  %w[beer brewery location guild event].each do |type|
    define_method(type) do
      body    = JSON.parse(request.raw_post)
      options = {
        action:     body['action'],
        id:         body['attributeId'],
        sub_action: body['subAction'].underscore
      }

      webhook = ::BreweryDB::Webhooks.const_get(type.classify).new(options)

      if webhook.process
        head :ok
      else
        head :unprocessable_entity
      end
    end
  end

  private
    def verify_nonce!
      secret = Digest::SHA1.hexdigest("#{ENV['BREWERY_DB_API_KEY']}#{params[:nonce]}")

      unless params[:key] == secret
        render json: { error: 'Nonce validation failed.' }, status: :unauthorized and return
      end
    end
end
