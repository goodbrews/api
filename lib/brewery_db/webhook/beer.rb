require 'brewery_db/webhook/base'
require 'app/models/beer'

module BreweryDB
  module Webhook
    class Beer < Base
      class OrderingError < StandardError; end

      def process
        @beer = ::Beer.find_or_initialize_by(brewerydb_id: @brewerydb_id)
        self.send(@action)
      end

      private

        def insert(attributes = nil)
          params = {
            withBreweries: 'Y',
            withSocialAccounts: 'Y',
            withIngredients: 'Y'
          }

          attributes ||= @client.get("/beer/#{@brewerydb_id}", params).body['data']

          @beer.assign_attributes(
            name:                attributes['name'],
            description:         attributes['description'],
            abv:                 attributes['abv'],
            ibu:                 attributes['ibu'],
            original_gravity:    attributes['originalGravity'],
            organic:             attributes['isOrganic'] == 'Y',
            serving_temperature: attributes['servingTemperatureDisplay'],
            availability:        attributes['available'].try(:[], 'name'),
            glassware:           attributes['glass'].try(:[], 'name'),

            created_at:          attributes['createDate'],
            updated_at:          attributes['updateDate']
          )

          # Handle images
          if attributes['labels']
            @beer.image_id = attributes['labels']['icon'].match(/upload_(\w+)-icon/)[1]
          end

          # Assign Style
          @beer.style = ::Style.find(attributes['styleId']) if attributes['styleId']

          @beer.save!

          # Handle associations
          unless @action == 'edit'
            brewery_insert(Array(attributes['breweries']))
            socialaccount_insert(Array(attributes['socialAccounts']))
            ingredient_insert(attributes['ingredients'] || {})
          end
        end

        def edit
          @sub_action ? self.send(@sub_action) : insert
        end

        def delete
          @beer.destroy!
        end

        def brewery_insert(breweries = nil)
          breweries ||= @client.get("/beer/#{@brewerydb_id}/breweries").body['data']
          brewery_ids = Array(breweries).map { |b| b['id'] }
          breweries   = ::Brewery.where(brewerydb_id: brewery_ids)

          if breweries.count == brewery_ids.count
            @beer.breweries = breweries
          else
            raise OrderingError, 'Received a new beer before we had its breweries!'
          end
        end
        alias :brewery_delete :brewery_insert

        # This is a no-op; we get the same information in a Brewery hook.
        def brewery_edit
          true
        end

        def event_insert(events = nil)
          events  ||= @client.get("/beer/#{@brewerydb_id}/events").body['data']
          event_ids = Array(events).map { |e| e['id'] }
          events    = ::Event.where(brewerydb_id: event_ids)

          if events.count == event_ids.count
            @beer.events = events
          else
            raise OrderingError, 'Received a new beer before we had its events!'
          end
        end
        alias :event_delete :event_insert

        # This is a no-op; we get the same information in an Event hook.
        def event_edit
          true
        end

        def ingredient_insert(attributes = nil)
          attributes ||= @client.get("/beer/#{@brewerydb_id}/ingredients").body['data']
          attributes   = attributes.flat_map { |_, i| i } if attributes.is_a?(Hash)
          return if attributes.empty?

          # Because there is no Ingredient webhook, ingredients pulled from
          # BreweryDB may not be in the local database yet. As such, we must
          # initialize and/or update ingredients here.
          ingredients = attributes.map do |attrs|
            ingredient = ::Ingredient.find_or_initialize_by(id: attrs['id'])
            ingredient.assign_attributes(
              name:       attrs['name'],
              category:   attrs['categoryDisplay'],
              created_at: attrs['createDate'],
              updated_at: attrs['updateDate']
            )
            ingredient.save!
            ingredient
          end

          @beer.ingredients = ingredients
        end
        alias :ingredient_delete :ingredient_insert

        def socialaccount_insert(attributes = nil)
          attributes ||= @client.get("/beer/#{@brewerydb_id}/socialaccounts").body['data']

          Array(attributes).each do |account|
            social_account = @beer.social_media_accounts.find_or_initialize_by(website: account['socialMedia']['name'])
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
          attributes ||= @client.get("/beer/#{@brewerydb_id}/socialaccounts").body['data']
          websites = attributes.map { |a| a['socialMedia']['name'] }

          @beer.social_media_accounts.where.not(website: websites).destroy_all
        end

        # We don't care about this.
        def upc_insert
          true
        end
        alias :upc_delete :upc_insert
    end
  end
end
