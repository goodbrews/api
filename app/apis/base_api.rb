require 'app/helpers/authorization_helper'

class BaseAPI < Crepe::API
  rescue_from(ActiveRecord::RecordNotFound) { error! :not_found }
  helper AuthorizationHelper

  helper do
    def query_params
      @query_params ||= env['rack.request.query_hash'].with_indifferent_access
    end

    def url
      @url ||= URI(request.url).to_s.gsub(/\?.*/, '')
    end
  end
end
