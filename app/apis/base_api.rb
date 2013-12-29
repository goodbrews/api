require 'app/helpers/authorization_helper'

class BaseAPI < Crepe::API
  rescue_from(ActiveRecord::RecordNotFound) { error! :not_found }

  helper AuthorizationHelper
end
