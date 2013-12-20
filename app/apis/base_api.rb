require 'app/helpers/pagination_helper'

class BaseAPI < Crepe::API
  helper Crepe::Helper::URLFor
  helper PaginationHelper
  respond_to :json
end
