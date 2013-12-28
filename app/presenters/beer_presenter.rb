require 'app/models/beer'
require 'app/presenters/paginated_presenter'
require 'app/presenters/ingredient_presenter'
require 'app/presenters/social_media_account_presenter'
require 'app/presenters/style_presenter'

class BeerPresenter < Jsonite
  properties :name, :description, :availability, :glassware, :organic,
             :abv, :ibu, :original_gravity, :serving_temperature

  property(:breweries)   { breweries_count }
  property(:events)      { events_count }

  embed :style do |context|
    throw :ignore unless style.present?
    StylePresenter.present(style, context: context, root: nil)
  end

  embed :ingredients, with: IngredientPresenter
  embed :social_media_accounts, with: SocialMediaAccountPresenter

  link { "/beers/#{self.to_param}" }

  %w[like dislike cellar hide].each do |action|
    link action, method: 'POST' do |context|
      throw :ignore unless context.authorized?

      "/beers/#{self.to_param}/#{action}"
    end

    link "un#{action}", method: 'DELETE' do |context|
      throw :ignore unless context.authorized?

      "/beers/#{self.to_param}/#{action}"
    end
  end

  link :style do |context|
    throw :ignore unless style.present?

    "/styles/#{style.to_param}"
  end

  link(:breweries) { "/beers/#{self.to_param}/breweries" }
  link(:events)    { "/beers/#{self.to_param}/events" }

  link :image, templated: true, size: %w[icon medium large] do |context|
    throw :ignore unless image_id.present?
    "https://s3.amazonaws.com/brewerydbapi/beer/#{brewerydb_id}/upload_#{image_id}-{size}.png"
  end
end

class BeersPresenter < PaginatedPresenter
  property(:beers, with: BeerPresenter) { to_a }
end
