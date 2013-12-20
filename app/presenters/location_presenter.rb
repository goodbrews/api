require 'app/models/location'

class LocationPresenter < Jsonite
  properties :name, :category, :primary, :in_planning, :public, :closed,
             :hours, :website, :phone, :street, :street2, :city, :region,
             :postal_code, :country, :latitude, :longitude
end
