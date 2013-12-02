module BreweryDB
  module Webhook
    class Base
      def initialize(options)
        @client       = BreweryDB::Client.new
        @action       = options[:action]
        @sub_action   = options[:sub_action]
        @brewerydb_id = options[:id]
      end

      def process
        # Implement in subclasses.
        raise 'Not implemented!'
      end
    end
  end
end
