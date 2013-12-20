require 'app/models/beer'

class BeerPresenter < Jsonite
  properties :name, :description, :availability, :glassware, :organic,
             :abv, :ibu, :original_gravity, :serving_temperature

  # TODO: Embed this instead
  property(:style)       { style_id }
  property(:breweries)   { breweries.count }
  property(:events)      { events.count }
  property(:ingredients) { ingredients.count }

  link             { "/beers/#{self.to_param}" }
  link(:style)     { "/styles/#{style.to_param}" }
  link(:breweries) { "/beers/#{self.to_param}/breweries" }
  link(:events)    { "/beers/#{self.to_param}/events" }

  link :image, templated: true, size: %w[icon medium large] do |context|
    "https://s3.amazonaws.com/brewerydbapi/beer/#{brewerydb_id}/upload_#{image_id}-{size}.png"
  end
end
