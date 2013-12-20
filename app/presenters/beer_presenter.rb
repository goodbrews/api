require 'app/models/beer'
require 'app/presenters/ingredient_presenter'
require 'app/presenters/social_media_account_presenter'
require 'app/presenters/style_presenter'

class BeerPresenter < Jsonite
  properties :name, :description, :availability, :glassware, :organic,
             :abv, :ibu, :original_gravity, :serving_temperature

  property(:breweries)   { breweries.count }
  property(:events)      { events.count }

  embed :style, with: StylePresenter
  embed :ingredients, with: IngredientPresenter
  embed :social_media_accounts, with: SocialMediaAccountPresenter

  link             { "/beers/#{self.to_param}" }
  link(:style)     { "/styles/#{style.to_param}" }
  link(:breweries) { "/beers/#{self.to_param}/breweries" }
  link(:events)    { "/beers/#{self.to_param}/events" }

  link :image, templated: true, size: %w[icon medium large] do |context|
    "https://s3.amazonaws.com/brewerydbapi/beer/#{brewerydb_id}/upload_#{image_id}-{size}.png"
  end
end
