require 'spec_helper'
require 'app/presenters/guild_presenter'

describe GuildPresenter do
  let(:guild) { Factory(:guild) }

  it 'presents a guild with a root key' do
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

    hash = GuildPresenter.present(guild, context: self)

    expect(hash).to eq(expected)
  end
end

describe GuildsPresenter do
  let(:context) do
    double.tap do |d|
      allow(d).to receive(:params).and_return({})
    end
  end

  before { 2.times { Factory(:guild) } }

  it 'presents a collection of guilds' do
    guilds = Guild.all
    expected = {
      'count' => 2,
      'guilds' => [
        GuildPresenter.new(guilds.first, context: context, root: nil).present,
        GuildPresenter.new(guilds.last,  context: context, root: nil).present
      ]
    }

    presented = GuildsPresenter.new(guilds, context: context, root: nil).present

    expect(presented).to eq(expected)
  end
end
