module BreweryDB
  module Webhooks
    class Event < Base
      def process
        @event = ::Event.find_or_initialize_by(brewerydb_id: @brewerydb_id)
        self.send(@action)
      end

      private
        def insert(attributes = nil)
          attributes ||= @client.get("/event/#{@brewerydb_id}").body['data']

          @event.assign_attributes({
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
            @event.image_id = attributes['images']['icon'].match(/upload_(\w+)-icon/)[1]
          end

          @event.save!

          brewery_insert
          beer_insert
          socialaccount_insert
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
          @event.destroy!
        end

        def beer_insert(attributes = nil)
          beers  ||= @client.get("/event/#{@brewerydb_id}/beers").body['data']
          beer_ids = Array(beers).map { |b| b['id'] }
          @event.beers = ::Beer.where(brewerydb_id: beer_ids)
        end
        alias :beer_delete :beer_insert

        # No-op; we'll get this information in a Beer webhook.
        def beer_edit(attributes = nil)
          true
        end

        def brewery_insert(attributes = nil)
          breweries      ||= @client.get("/event/#{@brewerydb_id}/breweries").body['data']
          brewery_ids      = Array(breweries).map { |b| b['id'] }
          @event.breweries = ::Brewery.where(brewerydb_id: brewery_ids)
        end
        alias :brewery_delete :brewery_insert

        # No-op; we'll get this information in a Brewery webhook.
        def brewery_edit(attributes = nil)
          true
        end

        def socialaccount_insert(attributes = nil)
          attributes ||= @client.get("/event/#{@brewerydb_id}/socialaccounts").body['data']
          Array(attributes).each do |account|
            social_account = @event.social_media_accounts.find_or_initialize_by(website: account['socialMedia']['name'])
            social_account.assign_attributes(
              handle:     account['handle'],
              created_at: account['createDate'],
              updated_at: account['updateDate']
            )

            social_account.save!
          end
        end
        alias :socialaccount_edit :socialaccount_insert

        def socialaccount_delete(attributes = nil)
          attributes ||= @client.get("/event/#{@brewerydb_id}/socialaccounts").body['data']
          websites = attributes.map { |a| a['socialMedia']['name'] }
          @event.social_media_accounts.where.not(website: websites).destroy_all
        end
    end
  end
end
