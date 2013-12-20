require 'spec_helper'
require 'app/presenters/event_presenter'

describe EventPresenter do
  let(:events) { [Factory(:event), Factory(:event)] }

  it 'presents an event with a root key' do
    event = events.first

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
          'self'      => { href: "/events/#{event.to_param}" },
          'beers'     => { href: "/events/#{event.to_param}/beers" },
          'breweries' => { href: "/events/#{event.to_param}/breweries" },
          'image'     => {
            href:      "https://s3.amazonaws.com/brewerydbapi/event/#{event.brewerydb_id}/upload_#{event.image_id}-{size}.png",
            templated: true,
            size:      %w[icon medium large]
          }
        }
      }
    }

    hash = EventPresenter.present(events.first, context: self)

    expect(hash).to eq(expected)
  end

  it 'presents an array of events without root keys' do
    expected = [
      EventPresenter.present(events.first, context: self)['event'],
      EventPresenter.present(events.last,  context: self)['event']
    ]

    expect(EventPresenter.present(events, context: self)).to eq(expected)
  end
end
