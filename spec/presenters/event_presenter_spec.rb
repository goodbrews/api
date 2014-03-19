require 'spec_helper'
require 'app/presenters/event_presenter'

describe EventPresenter do
  let(:event) { Factory(:event) }

  it 'presents an event with a root key' do
    expected = {
      'event' => {
        'name'        => event.name,
        'description' => event.description,
        'category'    => event.category,
        'year'        => event.year,
        'start_date'  => event.start_date,
        'end_date'    => event.end_date,
        'hours'       => event.hours,
        'price'       => event.price,
        'website'     => event.website,
        'phone'       => event.phone,

        'venue'       => event.venue,
        'street'      => event.street,
        'street2'     => event.street2,
        'city'        => event.city,
        'region'      => event.region,
        'postal_code' => event.postal_code,
        'country'     => event.country,
        'latitude'    => event.latitude,
        'longitude'   => event.longitude,

        'beers'       => event.beers.count,
        'breweries'   => event.breweries.count,

        '_embedded' => {
          'social_media_accounts' => SocialMediaAccountPresenter.present(event.social_media_accounts, context: self)
        },

        '_links' => {
          'self'      => { 'href' => "/events/#{event.to_param}" },
          'beers'     => { 'href' => "/events/#{event.to_param}/beers" },
          'breweries' => { 'href' => "/events/#{event.to_param}/breweries" },
          'image'     => {
            'href' =>  "https://s3.amazonaws.com/brewerydbapi/event/#{event.brewerydb_id}/upload_#{event.image_id}-{size}.png",
            templated: true,
            size:      %w[icon medium large]
          }
        }
      }
    }

    hash = EventPresenter.present(event, context: self)

    expect(hash).to eq(expected)
  end
end

describe EventsPresenter do
  let(:context) do
    double.tap do |d|
      allow(d).to receive(:authorized?).and_return(false)
      allow(d).to receive(:params).and_return({})
    end
  end

  before { 2.times { Factory(:event) } }

  it 'presents a collection of events' do
    events = Event.all
    expected = {
      'count' => 2,
      'events' => [
        EventPresenter.new(events.first, context: context, root: nil).present,
        EventPresenter.new(events.last,  context: context, root: nil).present
      ]
    }

    presented = EventsPresenter.new(events, context: context, root: nil).present

    expect(presented['count']).to eq(expected['count'])
    expect(presented['events']).to match_array(expected['events'])
  end
end
