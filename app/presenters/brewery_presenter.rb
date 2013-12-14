require 'app/models/brewery'

class BreweryPresenter < Jsonite
  properties :name, :alternate_names, :description, :website, :organic, :established

  property(:beers)     { beers.count }
  property(:events)    { events.count }
  property(:guilds)    { guilds.count }
  property(:locations) { locations.count } # TODO: Embed locations instead.

  link { "/breweries/#{self.to_param}" }

  # TODO: Create a simple url_for helper that joins URL fragments and calls
  # to_param on objects that respond to it.
  link(:beers)     { "/breweries/#{self.to_param}/beers" }
  link(:events)    { "/breweries/#{self.to_param}/events" }
  link(:guilds)    { "/breweries/#{self.to_param}/guilds" }
  link(:locations) { "/breweries/#{self.to_param}/locations" }

  link :image, templated: true, size: %w[icon medium large] do |context|
    "https://s3.amazonaws.com/brewerydbapi/brewery/#{brewerydb_id}/upload_#{image_id}-{size}.png"
  end
end
