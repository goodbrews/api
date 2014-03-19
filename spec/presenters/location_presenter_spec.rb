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
end

describe LocationsPresenter do
  let(:context) do
    double.tap do |d|
      allow(d).to receive(:params).and_return({})
    end
  end

  before { 2.times { Factory(:location) } }

  it 'presents a collection of locations' do
    locations = Location.all
    expected = {
      'count' => 2,
      'locations' => [
        LocationPresenter.new(locations.first, context: context, root: nil).present,
        LocationPresenter.new(locations.last,  context: context, root: nil).present
      ]
    }

    presented = LocationsPresenter.new(locations, context: context, root: nil).present

    expect(presented['count']).to eq(expected['count'])
    expect(presented['locations']).to match_array(expected['locations'])
  end
end
