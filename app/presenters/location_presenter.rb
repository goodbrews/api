require 'app/models/location'
require 'app/presenters/paginated_presenter'

class LocationPresenter < Jsonite
  properties :name, :category, :primary, :in_planning, :public, :closed,
             :hours, :website, :phone, :street, :street2, :city, :region,
             :postal_code, :country, :latitude, :longitude
end

class LocationsPresenter < PaginatedPresenter
  property(:locations, with: LocationPresenter) { to_a }
end
