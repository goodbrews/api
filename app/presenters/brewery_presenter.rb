require 'app/models/brewery'
require 'app/presenters/location_presenter'
require 'app/presenters/social_media_account_presenter'

class BreweryPresenter < Jsonite
  properties :name, :alternate_names, :description, :website, :organic, :established

  property(:beers)     { beers.count }
  property(:events)    { events.count }
  property(:guilds)    { guilds.count }

  embed :locations, with: LocationPresenter
  embed :social_media_accounts, with: SocialMediaAccountPresenter

  link             { "/breweries/#{self.to_param}" }
  link(:beers)     { "/breweries/#{self.to_param}/beers" }
  link(:events)    { "/breweries/#{self.to_param}/events" }
  link(:guilds)    { "/breweries/#{self.to_param}/guilds" }

  link :image, templated: true, size: %w[icon medium large] do |context|
    "https://s3.amazonaws.com/brewerydbapi/brewery/#{brewerydb_id}/upload_#{image_id}-{size}.png"
  end
end
