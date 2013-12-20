require 'app/models/guild'

class GuildPresenter < Jsonite
  properties :name, :description, :established, :website

  property(:breweries) { breweries.count }

  link             { "/guilds/#{self.to_param}" }
  link(:breweries) { "/guilds/#{self.to_param}/breweries" }

  link :image, templated: true, size: %w[icon medium large] do |context|
    "https://s3.amazonaws.com/brewerydbapi/guild/#{brewerydb_id}/upload_#{image_id}-{size}.png"
  end
end
