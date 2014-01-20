ENV['BREWERY_DB_API_KEY'] ||= 'secret_api_key'

Mail.defaults do
  delivery_method :test
end
