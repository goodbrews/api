module BreweryDB
  module Webhooks
    class Brewery < Base
      def process
        @brewery = ::Brewery.find_or_initialize_by(brewerydb_id: @brewerydb_id)
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

          @brewery.assign_attributes({
            name:        attributes['name'],
            website:     attributes['website'],
            description: attributes['description'],
            established: attributes['established'],
            organic:     attributes['isOrganic'] == 'Y',

            created_at:  attributes['createDate'],
            updated_at:  attributes['updateDate']
          })

          if attributes['images']
            @brewery.image_id = attributes['images']['icon'].match(/upload_(\w+)-icon/)[1]
          end

          @brewery.save!

          # Handle social accounts
          unless @action == 'edit'
            guild_insert(Array(attributes['guilds']))
            socialaccount_insert(Array(attributes['socialAccounts']))
            alternatename_insert(attributes['alternateNames'] || [])
            # beer_insert
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
          @brewery.destroy!
        end

        def alternatename_insert(attributes = nil)
          attributes ||= @client.get("/brewery/#{@brewerydb_id}/alternatenames").body['data']
          return if attributes.empty?

          @brewery.alternate_names = attributes.map { |alt| alt['altName'] }
          @brewery.save!
        end
        alias :alternatename_delete :alternatename_insert

        def beer_insert(attributes = nil)
          beers  ||= @client.get("/brewery/#{@brewerydb_id}/beers").body['data']
          beer_ids = Array(beers).map { |b| b['id'] }
          @brewery.beers = ::Beer.where(brewerydb_id: beer_ids)
        end
        alias :beer_delete :beer_insert

        # This is a no-op; we get the same information in a Beer hook.
        def beer_edit(attributes = nil)
          true
        end

        def event_insert(attributes = nil)
          events ||= @client.get("/brewery/#{@brewerydb_id}/events").body['data']
          event_ids       = Array(events).map { |e| e['id'] }
          @brewery.events = ::Event.where(brewerydb_id: event_ids)
        end
        alias :event_delete :event_insert

        # This is a no-op; we get the same information in an Event hook.
        def event_edit(attributes = nil)
          true
        end

        def guild_insert(attributes = nil)
          attributes ||= @client.get("/beer/#{@brewerydb_id}/guilds").body['data']
          guild_ids       = Array(attributes).map { |g| g['id'] }
          @brewery.guilds = ::Guild.where(brewerydb_id: guild_ids)
        end
        alias :guild_delete :guild_insert

        # This is a no-op; we get the same information in an Guild hook.
        def guild_edit(attributes = nil)
          true
        end

        def socialaccount_insert(attributes = nil)
          attributes ||= @client.get("/brewery/#{@brewerydb_id}/socialaccounts").body['data']
          Array(attributes).each do |account|
            social_account = @brewery.social_media_accounts.find_or_initialize_by(website: account['socialMedia']['name'])
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
          attributes ||= @client.get("/brewery/#{@brewerydb_id}/socialaccounts").body['data']
          websites = attributes.map { |a| a['socialMedia']['name'] }
          @brewery.social_media_accounts.where.not(website: websites).destroy_all
        end

        # These are no-ops; we get the same information in a Location hook
        %w[insert delete edit].each do |action|
          define_method "location_#{action}" do
            true
          end
        end
    end
  end
end
