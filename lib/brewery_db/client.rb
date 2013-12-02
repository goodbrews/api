require 'net/http'
require 'json'

module BreweryDB
  class Client
    class Error < RuntimeError
      attr_reader :response

      def initialize(response)
        @response, @json = response, JSON.parse(response.body)
      end

      def body() @json end
      def message() body['errorMessage'] end
      alias :error :message
    end

    class Response
      attr_reader :body

      def initialize(response)
        @body = JSON.parse(response.body)
      end
    end

    CONTENT_TYPE = 'application/json'
    METHODS = {
      :get    => Net::HTTP::Get,
      :post   => Net::HTTP::Post,
      :put    => Net::HTTP::Put,
      :delete => Net::HTTP::Delete
    }
    HOST = 'api.brewerydb.com'
    BASE_PATH = '/v2'
    PORT = 443

    def initialize(api_key = ENV['BREWERY_DB_API_KEY'])
      @api_key = api_key
    end

    METHODS.each do |method, _|
      define_method(method) do |path, params = {}, options = {}|
        request method, path, options.merge(params: params)
      end
    end

    private

      def request(method, path, options)
        uri = uri_for(path, options[:params])
        req = METHODS[method].new(uri.to_s, 'Accept' => CONTENT_TYPE)

        if options.key?(:body)
          req['Content-Type'] = CONTENT_TYPE
          req.body = options[:body] ? JSON.dump(options[:body]) : ''
        end

        http = Net::HTTP.new(HOST, PORT)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        res = http.start { http.request(req) }

        case res
        when Net::HTTPSuccess
          return Response.new(res)
        else
          raise Error, res
        end
      end

      def uri_for(path, params = {})
        uri = URI(path)
        uri.path = BASE_PATH + uri.path unless uri.path =~ %r{^/v\d}

        query = Rack::Utils.parse_nested_query(uri.query)
        query.merge!(params.stringify_keys)
        query.merge!('key' => @api_key)
        uri.query = query.to_query

        uri
      end
  end
end
