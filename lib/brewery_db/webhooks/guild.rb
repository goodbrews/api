module BreweryDB
  module Webhooks
    class Guild < Base
      def process
        @guild = ::Guild.find_or_initialize_by(brewerydb_id: @brewerydb_id)
        self.send(@action)
      end

      private
        def insert(attributes = nil)
          attributes ||= @client.get("/guild/#{@brewerydb_id}").body['data']

          @guild.assign_attributes({
            name:        attributes['name'],
            description: attributes['description'],
            website:     attributes['website'],
            established: attributes['established'],

            created_at:  attributes['createDate'],
            updated_at:  attributes['updateDate']
          })

          if attributes['images']
            @guild.image_id = attributes['images']['icon'].match(/upload_(\w+)-icon/)[1]
          end

          @guild.save!

          unless @action == 'edit'
            brewery_insert
            socialaccount_insert
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
          @guild.destroy!
        end

        def brewery_insert(attributes = nil)
          breweries      ||= @client.get("/guild/#{@brewerydb_id}/breweries").body['data']
          brewery_ids      = Array(breweries).map { |b| b['id'] }
          @guild.breweries = ::Brewery.where(brewerydb_id: brewery_ids)
        end
        alias :brewery_delete :brewery_insert

        # This is a no-op. We'll get this information in a Brewery webhook.
        def brewery_edit(attributes = nil)
          true
        end

        def socialaccount_insert(attributes = nil)
          attributes ||= @client.get("/guild/#{@brewerydb_id}/socialaccounts").body['data']
          Array(attributes).each do |account|
            social_account = @guild.social_media_accounts.find_or_initialize_by(website: account['socialMedia']['name'])
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
          attributes ||= @client.get("/guild/#{@brewerydb_id}/socialaccounts").body['data']
          websites = attributes.map { |a| a['socialMedia']['name'] }
          @guild.social_media_accounts.where.not(website: websites).destroy_all
        end
    end
  end
end
