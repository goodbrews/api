require 'app/models/event'
require 'app/presenters/social_media_account_presenter'

class EventPresenter < Jsonite
  properties :name, :description, :category, :year, :start_date, :end_date,
             :hours, :price, :venue, :street, :street2, :city, :region,
             :postal_code, :country, :latitude, :longitude, :website, :phone

  property(:beers)     { beers.count }
  property(:breweries) { breweries.count }

  embed :social_media_accounts, with: SocialMediaAccountPresenter

  link             { "/events/#{self.to_param}" }
  link(:beers)     { "/events/#{self.to_param}/beers" }
  link(:breweries) { "/events/#{self.to_param}/breweries" }

  link :image, templated: true, size: %w[icon medium large] do |context|
    throw :ignore unless image_id.present?
    "https://s3.amazonaws.com/brewerydbapi/event/#{brewerydb_id}/upload_#{image_id}-{size}.png"
  end
end
