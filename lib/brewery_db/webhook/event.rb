require 'brewery_db/webhook/base'
require 'brewery_db/webhook/concerns/social_accounts'
require 'app/models/event'

module BreweryDB
  module Webhook
    class Event < Base
      include SocialAccounts

      def process
        @model = ::Event.find_or_initialize_by(brewerydb_id: @brewerydb_id)
        self.send(@action)
      end

      private
        def insert(attributes = nil)
          attributes ||= @client.get("/event/#{@brewerydb_id}").body['data']

          @model.assign_attributes({
            name:        attributes['name'],
            year:        attributes['year'],
            description: attributes['description'],
            category:    attributes['typeDisplay'],

            start_date:  attributes['startDate'],
            end_date:    attributes['endDate'],
            hours:       attributes['time'],
            price:       attributes['price'],

            venue:       attributes['venueName'],
            street:      attributes['streetAddress'],
            street2:     attributes['extendedAddress'],
            city:        attributes['locality'],
            region:      attributes['region'],
            postal_code: attributes['postalCode'],
            country:     attributes['countryIsoCode'],

            latitude:    attributes['latitude'],
            longitude:   attributes['longitude'],

            website:     attributes['website'],
            phone:       attributes['phone'],

            created_at:  attributes['createDate'],
            updated_at:  attributes['updateDate']
          })

          if attributes['images']
            @model.image_id = attributes['images']['icon'].match(/upload_(\w+)-icon/)[1]
          end

          @model.save!

          unless @action == 'edit'
            brewery_insert
            beer_insert
            socialaccount_insert
          end
        end

        def edit(attributes = nil)
          if @sub_action
            # We don't care about award-based sub actions at this time.
            @sub_action =~ /award/ ? true : send(@sub_action)
          else
            insert
          end
        end

        def delete(attributes = nil)
          @model.destroy!
        end

        def beer_insert(attributes = nil)
          beers  ||= @client.get("/event/#{@brewerydb_id}/beers").body['data']
          beer_ids = Array(beers).map { |b| b['beerId'] }
          beers    = ::Beer.where(brewerydb_id: beer_ids)

          if beers.count == beer_ids.count
            @model.beers = beers
          else
            raise OrderingError, 'Received a new event before we had its beers!'
          end
        end
        alias :beer_delete :beer_insert

        # No-op; we'll get this information in a Beer webhook.
        def beer_edit(attributes = nil)
          true
        end

        def brewery_insert(attributes = nil)
          breweries ||= @client.get("/event/#{@brewerydb_id}/breweries").body['data']
          brewery_ids = Array(breweries).map { |b| b['breweryId'] }
          breweries   = ::Brewery.where(brewerydb_id: brewery_ids)

          if breweries.count == brewery_ids.count
            @model.breweries = breweries
          else
            raise OrderingError, 'Received a new event before we had its breweries!'
          end
        end
        alias :brewery_delete :brewery_insert

        # No-op; we'll get this information in a Brewery webhook.
        def brewery_edit(attributes = nil)
          true
        end
    end
  end
end
