require 'spec_helper'
require 'app/presenters/guild_presenter'

describe GuildPresenter do
  let(:guilds) { [Factory(:guild), Factory(:guild)] }

  it 'presents a guild with a root key' do
    guild = guilds.first

    expected = {
      'guild' => {
        'name'        => guild.name,
        'description' => guild.description,
        'established' => guild.established,
        'website'     => guild.website,

        'breweries'   => guild.breweries.count,

        '_embedded' => {
          'social_media_accounts' => SocialMediaAccountPresenter.present(guild.social_media_accounts, context: self)
        },

        '_links' => {
          'self'      => { 'href' => "/guilds/#{guild.to_param}" },
          'breweries' => { 'href' => "/guilds/#{guild.to_param}/breweries" },
          'image'     => {
            'href' =>  "https://s3.amazonaws.com/brewerydbapi/guild/#{guild.brewerydb_id}/upload_#{guild.image_id}-{size}.png",
            templated: true,
            size:      %w[icon medium large]
          }
        }
      }
    }

    hash = GuildPresenter.present(guilds.first, context: self)

    expect(hash).to eq(expected)
  end

  it 'presents an array of guilds without root keys' do
    expected = [
      GuildPresenter.present(guilds.first, context: self)['guild'],
      GuildPresenter.present(guilds.last,  context: self)['guild']
    ]

    expect(GuildPresenter.present(guilds, context: self)).to eq(expected)
  end
end
