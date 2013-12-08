require 'brewery_db/webhook/base'
require 'brewery_db/webhook/concerns/social_accounts'
require 'app/models/guild'

module BreweryDB
  module Webhook
    class Guild < Base
      include SocialAccounts

      def process
        @model = ::Guild.find_or_initialize_by(brewerydb_id: @brewerydb_id)
        self.send(@action)
      end

      private
        def insert(attributes = nil)
          params = { withSocialAccounts: 'Y' }
          attributes ||= @client.get("/guild/#{@brewerydb_id}", params).body['data']

          @model.assign_attributes({
            name:        attributes['name'],
            description: attributes['description'],
            website:     attributes['website'],
            established: attributes['established'],

            created_at:  attributes['createDate'],
            updated_at:  attributes['updateDate']
          })

          if attributes['images']
            @model.image_id = attributes['images']['icon'].match(/upload_(\w+)-icon/)[1]
          end

          @model.save!

          unless @action == 'edit'
            brewery_insert
            socialaccount_insert(attributes['socialAccounts'])
          end
        end

        def edit
          if @sub_action
            self.send(@sub_action)
          else
            insert
          end
        end

        def delete
          @model.destroy!
        end

        def brewery_insert(attributes = nil)
          breweries ||= @client.get("/guild/#{@brewerydb_id}/breweries").body['data']
          brewery_ids = Array(breweries).map { |b| b['id'] }
          breweries   = ::Brewery.where(brewerydb_id: brewery_ids)

          if breweries.count == brewery_ids.count
            @model.breweries = breweries
          else
            raise OrderingError, 'Received a new guild before we had its breweries!'
          end
        end
        alias :brewery_delete :brewery_insert

        # This is a no-op. We'll get this information in a Brewery webhook.
        def brewery_edit(attributes = nil)
          true
        end
    end
  end
end
