require 'app/helpers/pagination_helper'

class BaseAPI < Crepe::API
  helper PaginationHelper
  respond_to :json
end
