require 'spec_helper'
require 'app/presenters/location_presenter'

describe LocationPresenter do
  let(:locations) { [Factory(:location), Factory(:location)] }

  it 'presents an location with a root key' do
    location = locations.first

    expected = {
      'location' => {
        'name'        => location.name,
        'category'    => location.category,
        'primary'     => location.primary,
        'in_planning' => location.in_planning,
        'public'      => location.public?,
        'closed'      => location.closed?,
        'hours'       => location.hours,
        'website'     => location.website,
        'phone'       => location.phone,

        'street'      => location.street,
        'street2'     => location.street2,
        'city'        => location.city,
        'region'      => location.region,
        'postal_code' => location.postal_code,
        'country'     => location.country,
        'latitude'    => location.latitude,
        'longitude'   => location.longitude
      }
    }

    hash = LocationPresenter.present(locations.first, context: self)

    expect(hash).to eq(expected)
  end

  it 'presents an array of locations without root keys' do
    expected = [
      LocationPresenter.present(locations.first, context: self)['location'],
      LocationPresenter.present(locations.last,  context: self)['location']
    ]

    expect(LocationPresenter.present(locations, context: self)).to eq(expected)
  end
end
