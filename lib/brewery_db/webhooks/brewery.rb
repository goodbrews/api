require 'brewery_db/webhooks/base'
require 'brewery_db/webhooks/concerns/events'
require 'brewery_db/webhooks/concerns/social_accounts'
require 'app/models/brewery'

module BreweryDB
  module Webhooks
    class Brewery < Base
      include Events
      include SocialAccounts

      def process
        @model = ::Brewery.find_or_initialize_by(brewerydb_id: @brewerydb_id)
        self.send(@action)
      end

      private
        def insert(attributes = nil)
          params = {
            withSocialAccounts: 'Y',
            withGuilds: 'Y',
            withLocations: 'Y',
            withAlternateNames: 'Y'
          }
          attributes ||= @client.get("/brewery/#{@brewerydb_id}", params).body['data']

          @model.assign_attributes({
            name:        attributes['name'],
            website:     attributes['website'],
            description: attributes['description'],
            established: attributes['established'],
            organic:     attributes['isOrganic'] == 'Y',

            created_at:  attributes['createDate'],
            updated_at:  attributes['updateDate']
          })

          if attributes['images']
            @model.image_id = attributes['images']['icon'].match(/upload_(\w+)-icon/)[1]
          end

          @model.save!

          # Handle associations and alternate names
          unless @action == 'edit'
            guild_insert(Array(attributes['guilds']))
            socialaccount_insert(Array(attributes['socialAccounts']))
            alternatename_insert(attributes['alternateNames'] || [])
          end
        end

        def edit(attributes = nil)
          if @sub_action
            send(@sub_action)
          else
            insert
          end
        end

        def delete
          @model.destroy!
        end

        def alternatename_insert(attributes = nil)
          attributes ||= @client.get("/brewery/#{@brewerydb_id}/alternatenames").body['data']
          return if attributes.empty?

          @model.alternate_names = attributes.map { |alt| alt['altName'] }
          @model.save!
        end
        alias :alternatename_delete :alternatename_insert

        def beer_insert(attributes = nil)
          beers      ||= @client.get("/brewery/#{@brewerydb_id}/beers").body['data']
          beer_ids     = Array(beers).map { |b| b['id'] }
          beers        = ::Beer.where(brewerydb_id: beer_ids)

          if beers.count == beer_ids.count
            @model.beers = beers
          else
            raise OrderingError, 'Received a brewery before we had its beers!'
          end
        end
        alias :beer_delete :beer_insert

        # This is a no-op; we get the same information in a Beer hook.
        def beer_edit(attributes = nil)
          true
        end

        def guild_insert(attributes = nil)
          attributes ||= @client.get("/brewery/#{@brewerydb_id}/guilds").body['data']
          guild_ids    = Array(attributes).map { |g| g['id'] }
          guilds       = ::Guild.where(brewerydb_id: guild_ids)

          if guilds.count == guild_ids.count
            @model.guilds = guilds
          else
            raise OrderingError, 'Received a brewery before we had its guilds!'
          end
        end
        alias :guild_delete :guild_insert

        # This is a no-op; we get the same information in an Guild hook.
        def guild_edit(attributes = nil)
          true
        end

        # These are no-ops; we get the same information in a Location hook
        def location_insert
          true
        end
        alias :location_delete :location_insert
        alias :location_edit :location_insert
    end
  end
end
