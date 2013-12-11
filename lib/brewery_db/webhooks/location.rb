require 'brewery_db/webhooks/base'
require 'app/models/location'

module BreweryDB
  module Webhooks
    class Location < Base
      def process
        self.send(@action)
      end

      private
        def edit(attributes = nil)
          location = ::Location.find_or_initialize_by(brewerydb_id: @brewerydb_id)
          attributes ||= @client.get("/location/#{@brewerydb_id}").body['data']

          location.assign_attributes({
            name:        attributes['name'],
            category:    attributes['locationTypeDisplay'],
            primary:     attributes['isPrimary'] == 'Y',
            in_planning: attributes['inPlanning'] == 'Y',
            public:      attributes['openToPublic'] == 'Y',
            closed:      attributes['isClosed'] == 'Y',

            street:      attributes['streetAddress'],
            street2:     attributes['extendedAddress'],
            city:        attributes['locality'],
            region:      attributes['region'],
            postal_code: attributes['postalCode'],
            country:     attributes['countryIsoCode'],

            latitude:    attributes['latitude'],
            longitude:   attributes['longitude'],

            phone:       attributes['phone'],
            website:     attributes['website'],
            hours:       attributes['hoursOfOperation'],

            created_at:  attributes['createDate'],
            updated_at:  attributes['updateDate']
          })

          if brewery = ::Brewery.find_by(brewerydb_id: attributes['breweryId'])
            location.brewery = brewery
            location.save!
            return location
          else
            raise OrderingError, 'Got a location before we had its brewery!'
          end
        end
        alias :insert :edit

        def delete
          ::Location.find_by(brewerydb_id: @brewerydb_id).destroy!
        end
    end
  end
end
