module BreweryDB
  module Webhooks
    class Base
      def initialize(options)
        @client       = BreweryDB::Client.new
        @action       = options[:action]
        @sub_action   = options[:sub_action]
        @brewerydb_id = options[:id]
      end

      def process
        # Override in inheritors.
        true
      end
    end
  end
end
