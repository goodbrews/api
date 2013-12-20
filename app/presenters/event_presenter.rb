require 'app/models/event'

class EventPresenter < Jsonite
  properties :name, :description, :category, :year, :start_date, :end_date,
             :hours, :price, :venue, :street, :street2, :city, :region,
             :postal_code, :country, :latitude, :longitude, :website, :phone

  property(:beers)     { beers.count }
  property(:breweries) { breweries.count }

  link             { "/events/#{self.to_param}" }
  link(:beers)     { "/events/#{self.to_param}/beers" }
  link(:breweries) { "/events/#{self.to_param}/breweries" }

  link :image, templated: true, size: %w[icon medium large] do |context|
    "https://s3.amazonaws.com/brewerydbapi/event/#{brewerydb_id}/upload_#{image_id}-{size}.png"
  end
end
