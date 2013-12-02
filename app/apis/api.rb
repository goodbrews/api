module Goodbrews
  class API < Grape::API
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    format :json
  end
end
