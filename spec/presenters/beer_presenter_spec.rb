require 'spec_helper'
require 'app/presenters/beer_presenter'

describe BeerPresenter do
  let(:beer) { Factory(:beer) }
  let(:context) do
    double.tap do |d|
      allow(d).to receive(:authorized?).and_return(false)
    end
  end

  it 'presents a beer with a root key' do
    expected = {
      'beer' => {
        'name'         => beer.name,
        'description'  => beer.description,
        'availability' => beer.availability,
        'glassware'    => beer.glassware,
        'organic'      => beer.organic,

        'abv'                 => beer.abv,
        'ibu'                 => beer.ibu,
        'original_gravity'    => beer.original_gravity,
        'serving_temperature' => beer.serving_temperature,

        'breweries' => beer.breweries.count,
        'events'    => beer.events.count,

        '_embedded' => {
          'style' => StylePresenter.present(beer.style, context: context)['style'],
          'ingredients' => IngredientPresenter.present(beer.ingredients, context: context),
          'social_media_accounts' => SocialMediaAccountPresenter.present(beer.social_media_accounts, context: self)
        },

        '_links' => {
          'self'      => { 'href' => "/beers/#{beer.to_param}" },
          'style'     => { 'href' => "/styles/#{beer.style.to_param}" },
          'breweries' => { 'href' => "/beers/#{beer.to_param}/breweries" },
          'events'    => { 'href' => "/beers/#{beer.to_param}/events" },
          'image'     => {
            'href'  => "https://s3.amazonaws.com/brewerydbapi/beer/#{beer.brewerydb_id}/upload_#{beer.image_id}-{size}.png",
            templated: true,
            size:      %w[icon medium large]
          }
        }
      }
    }

    hash = BeerPresenter.present(beer, context: context)

    expect(hash).to eq(expected)
  end

  it 'includes rating links when authorized' do
    allow(context).to receive(:authorized?).and_return(true)
    hash = BeerPresenter.present(beer, context: context)

    %w[like dislike cellar hide].each do |action|
      post_link = {
        action => {
          method: 'POST',
          'href' => "/beers/#{beer.to_param}/#{action}"
        }
      }

      delete_link = {
        "un#{action}" => {
          method: 'DELETE',
          'href' => "/beers/#{beer.to_param}/#{action}"
        }
      }

      expect(hash['beer']['_links']).to include(post_link)
      expect(hash['beer']['_links']).to include(delete_link)
    end
  end
end

describe BeersPresenter do
  let(:context) do
    double.tap do |d|
      allow(d).to receive(:authorized?).and_return(false)
      allow(d).to receive(:params).and_return({})
    end
  end

  before { 2.times { Factory(:beer) } }

  it 'presents a collection of beers' do
    beers = Beer.all
    expected = {
      'count' => 2,
      'beers' => [
        BeerPresenter.new(beers.first, context: context, root: nil).present,
        BeerPresenter.new(beers.last,  context: context, root: nil).present
      ]
    }

    presented = BeersPresenter.new(beers, context: context, root: nil).present

    expect(presented['count']).to eq(expected['count'])
    expect(presented['beers']).to match_array(expected['beers'])
  end
end
