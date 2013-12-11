module BreweryDB
  module Webhooks
    module SocialAccounts
      def socialaccount_insert(attributes = nil)
        attributes ||= @client.get("/#{self.class.to_s.demodulize.underscore}/#{@brewerydb_id}/socialaccounts").body['data']

        Array(attributes).each do |account|
          social_account = @model.social_media_accounts.find_or_initialize_by(website: account['socialMedia']['name'])
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
        attributes ||= @client.get("/#{self.class.to_s.demodulize.underscore}/#{@brewerydb_id}/socialaccounts").body['data']
        websites = attributes.map { |a| a['socialMedia']['name'] }

        @model.social_media_accounts.where.not(website: websites).destroy_all
      end
    end
  end
end
