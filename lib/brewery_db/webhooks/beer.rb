require 'brewery_db/webhooks/base'
require 'brewery_db/webhooks/concerns/events'
require 'brewery_db/webhooks/concerns/social_accounts'
require 'app/models/beer'

module BreweryDB
  module Webhooks
    class Beer < Base
      include SocialAccounts
      include Events

      def process
        @model = ::Beer.find_or_initialize_by(brewerydb_id: @brewerydb_id)
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

          @model.assign_attributes(
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
            @model.image_id = attributes['labels']['icon'].match(/upload_(\w+)-icon/)[1]
          end

          # Assign Style
          @model.style = ::Style.find(attributes['styleId']) if attributes['styleId']

          @model.save!

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
          @model.destroy!
        end

        def brewery_insert(breweries = nil)
          breweries ||= @client.get("/beer/#{@brewerydb_id}/breweries").body['data']
          brewery_ids = Array(breweries).map { |b| b['id'] }
          breweries   = ::Brewery.where(brewerydb_id: brewery_ids)

          if breweries.count == brewery_ids.count
            @model.breweries = breweries
          else
            raise OrderingError, 'Received an brewery insertion before we had the breweries!'
          end
        end
        alias :brewery_delete :brewery_insert

        # This is a no-op; we get the same information in a Brewery hook.
        def brewery_edit
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

          @model.ingredients = ingredients
        end
        alias :ingredient_delete :ingredient_insert

        # We don't care about this.
        def upc_insert
          true
        end
        alias :upc_delete :upc_insert
    end
  end
end
