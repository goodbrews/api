require 'app/workers/webhook_worker'

class NonceKey < Grape::Validations::Validator
  def validate_param!(key, params)
    secret = Digest::SHA1.hexdigest("#{ENV['BREWERY_DB_API_KEY']}#{params[:nonce]}")
    unless params[key] == secret
      raise Grape::Exceptions::Validation, param: @scope.full_name(key), message: "does not match our BreweryDB API key"
    end
  end
end

class WebhooksAPI < Grape::API
  namespace :brewery_db do
    namespace :webhooks do
      # Rather than route_param here, we define each endpoint so that New Relic
      # treats them as separate endpoints for better tracking.
      %w[beer brewery location guild event].each do |type|
        desc "The #{type} webhook provided by BreweryDB."
        params do
          requires :key, nonce_key: true
          requires :nonce, type: String
          requires :attributeId, type: String
          requires :action, type: String

          # These params are optional and only used if params[:action] is 'edit'
          optional :subAction, type: String
          optional :subAttributeId
        end
        post type do
          WebhookWorker.perform_async(params.merge(type: type))

          status 200
        end
      end
    end
  end
end
