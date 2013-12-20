require 'app/helpers/pagination_helper'

class BaseAPI < Crepe::API
  rescue_from(ActiveRecord::RecordNotFound) { error! :not_found }

  helper PaginationHelper

  respond_to :json
end
