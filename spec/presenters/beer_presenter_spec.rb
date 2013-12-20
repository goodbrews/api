require 'spec_helper'
require 'app/apis/base_api'
require 'app/presenters/beer_presenter'

describe BeerPresenter do
  let(:beers) { [Factory(:beer), Factory(:beer)] }

  it 'presents a brewery with a root key' do
    beer = beers.first

    expected = {
      'beer' => {
        'name'            => beer.name,
        'description'     => beer.description,
        'availability'    => beer.availability,
        'glassware'       => beer.glassware,
        'organic'         => beer.organic,

        'abv'                 => beer.abv,
        'ibu'                 => beer.ibu,
        'original_gravity'    => beer.original_gravity,
        'serving_temperature' => beer.serving_temperature,

        'style'       => beer.style_id,
        'breweries'   => beer.breweries.count,
        'events'      => beer.events.count,
        'ingredients' => beer.ingredients.count,

        '_links' => {
          'self'      => { href: "/beers/#{beer.to_param}" },
          'style'     => { href: "/styles/#{beer.style.to_param}" },
          'breweries' => { href: "/beers/#{beer.to_param}/breweries" },
          'events'    => { href: "/beers/#{beer.to_param}/events" },
          'image'     => {
            href:      "https://s3.amazonaws.com/brewerydbapi/beer/#{beer.brewerydb_id}/upload_#{beer.image_id}-{size}.png",
            templated: true,
            size:      %w[icon medium large]
          }
        }
      }
    }

    hash = BeerPresenter.present(beers.first, context: self)

    expect(hash).to eq(expected)
  end

  it 'presents an array of breweries without root keys' do
    expected = [
      BeerPresenter.present(beers.first, context: self)['beer'],
      BeerPresenter.present(beers.last,  context: self)['beer']
    ]

    expect(BeerPresenter.present(beers, context: self)).to eq(expected)
  end
end
