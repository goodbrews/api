require 'spec_helper'
require 'app/presenters/brewery_presenter'

describe BreweryPresenter do
  let(:breweries) { [Factory(:brewery), Factory(:brewery)] }

  it 'presents a brewery with a root key' do
    brewery = breweries.first

    expected = {
      'brewery' => {
        'name'            => brewery.name,
        'alternate_names' => brewery.alternate_names,
        'description'     => brewery.description,
        'website'         => brewery.website,
        'organic'         => brewery.organic,
        'established'     => brewery.established,

        'beers'           => brewery.beers.count,
        'events'          => brewery.events.count,
        'guilds'          => brewery.guilds.count,
        'locations'       => brewery.locations.count,

        '_links' => {
          'self'      => { href: "/breweries/#{brewery.to_param}" },
          'beers'     => { href: "/breweries/#{brewery.to_param}/beers"},
          'events'    => { href: "/breweries/#{brewery.to_param}/events"},
          'guilds'    => { href: "/breweries/#{brewery.to_param}/guilds"},
          'locations' => { href: "/breweries/#{brewery.to_param}/locations"},
          'image'     => {
            href:      "https://s3.amazonaws.com/brewerydbapi/brewery/#{brewery.brewerydb_id}/upload_#{brewery.image_id}-{size}.png",
            templated: true,
            size:      %w[icon medium large]
          }
        }
      }
    }

    hash = BreweryPresenter.present(breweries.first, context: self)

    expect(hash).to eq(expected)
  end

  it 'presents an array of breweries without root keys' do
    expected = [
      BreweryPresenter.present(breweries.first, context: self)['brewery'],
      BreweryPresenter.present(breweries.last,  context: self)['brewery']
    ]

    expect(BreweryPresenter.present(breweries, context: self)).to eq(expected)
  end
end
