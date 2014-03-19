require 'spec_helper'
require 'app/presenters/brewery_presenter'

describe BreweryPresenter do
  let(:brewery) { Factory(:brewery) }

  it 'presents a brewery with a root key' do
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

        '_embedded' => {
          'locations' => LocationPresenter.present(brewery.locations, context: self),
          'social_media_accounts' => SocialMediaAccountPresenter.present(brewery.social_media_accounts, context: self)
        },

        '_links' => {
          'self'      => { 'href' => "/breweries/#{brewery.to_param}" },
          'beers'     => { 'href' => "/breweries/#{brewery.to_param}/beers"},
          'events'    => { 'href' => "/breweries/#{brewery.to_param}/events"},
          'guilds'    => { 'href' => "/breweries/#{brewery.to_param}/guilds"},

          'image'     => {
            'href' =>  "https://s3.amazonaws.com/brewerydbapi/brewery/#{brewery.brewerydb_id}/upload_#{brewery.image_id}-{size}.png",
            templated: true,
            size:      %w[icon medium large]
          }
        }
      }
    }

    hash = BreweryPresenter.present(brewery, context: self)

    expect(hash).to eq(expected)
  end
end

describe BreweriesPresenter do
  let(:context) do
    double.tap do |d|
      allow(d).to receive(:params).and_return({})
    end
  end

  before { 2.times { Factory(:brewery) } }

  it 'presents a collection of breweries' do
    breweries = Brewery.all
    expected = {
      'count' => 2,
      'breweries' => [
        BreweryPresenter.new(breweries.first, context: context, root: nil).present,
        BreweryPresenter.new(breweries.last,  context: context, root: nil).present
      ]
    }

    presented = BreweriesPresenter.new(breweries, context: context, root: nil).present

    expect(presented['count']).to eq(expected['count'])
    expect(presented['breweries']).to match_array(expected['breweries'])
  end
end
