require 'spec_helper'
require 'app/presenters/brewery_presenter'

describe BreweryPresenter do
  let(:brewery) { Factory(:brewery) }
  let(:presenter) { BreweryPresenter.new(brewery) }

  it 'presents a brewery' do
    expected = {
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
        'self'      => { 'href' => "/breweries/#{brewery.to_param}" },
        'beers'     => { 'href' => "/breweries/#{brewery.to_param}/beers"},
        'events'    => { 'href' => "/breweries/#{brewery.to_param}/events"},
        'guilds'    => { 'href' => "/breweries/#{brewery.to_param}/guilds"},
        'locations' => { 'href' => "/breweries/#{brewery.to_param}/locations"},
        'image'     => {
          'href'      => "https://s3.amazonaws.com/brewerydbapi/brewery/#{brewery.brewerydb_id}/upload_#{brewery.image_id}-{size}.png",
          'templated' => true,
          'size'      => %w[icon medium large]
        }
      }
    }

    expect(JSON.parse(presenter.to_json)).to eq(expected)
  end
end
