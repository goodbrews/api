require 'app/models/guild'
require 'app/presenters/paginated_presenter'
require 'app/presenters/social_media_account_presenter'

class GuildPresenter < Jsonite
  properties :name, :description, :established, :website

  property(:breweries) { breweries_count }

  embed :social_media_accounts, with: SocialMediaAccountPresenter

  link             { "/guilds/#{self.to_param}" }
  link(:breweries) { "/guilds/#{self.to_param}/breweries" }

  link :image, templated: true, size: %w[icon medium large] do |context|
    throw :ignore unless image_id.present?
    "https://s3.amazonaws.com/brewerydbapi/guild/#{brewerydb_id}/upload_#{image_id}-{size}.png"
  end
end

class GuildsPresenter < PaginatedPresenter
  property(:guilds, with: GuildPresenter) { to_a }
end
