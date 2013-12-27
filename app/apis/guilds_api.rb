require 'app/apis/base_api'
require 'app/models/guild'
require 'app/presenters/brewery_presenter'
require 'app/presenters/guild_presenter'

class GuildsAPI < BaseAPI
  get { GuildPresenter.present paginate(Guild.all), context: self }

  param :id do
    let(:guild) { Guild.from_param(params[:id]) }

    get { GuildPresenter.present(guild, context: self) }

    get :breweries do
      BreweryPresenter.present paginate(guild.breweries), context: self
    end
  end
end
