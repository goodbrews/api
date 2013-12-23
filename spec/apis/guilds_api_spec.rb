require 'spec_helper'
require 'app/apis/guilds_api'

describe GuildsAPI do
  def app
    Goodbrews::API
  end

  let(:context) do
    double.tap do |d|
      allow(d).to receive(:authorized?).and_return(false)
    end
  end

  context '/guilds' do
    it 'returns an empty array' do
      get '/guilds'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('[]')
    end

    it 'returns a list of guilds as JSON' do
      guild = Factory(:guild)
      body = GuildPresenter.present([guild], context: context)

      get '/guilds'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(body.to_json)
    end
  end

  context '/guilds/:id' do
    context 'without an existing guild' do
      it 'returns a 404' do
        get '/guilds/nothing-here'

        expect(last_response.status).to eq(404)
      end
    end

    context 'with an existing guild' do
      let(:guild) { Factory(:guild) }

      it 'returns an existing guild as json' do
        body = GuildPresenter.present(guild, context: context)

        get "/guilds/#{guild.to_param}"

        expect(last_response.body).to eq(body.to_json)
      end

      context '/breweries' do
        it 'returns an empty array' do
          get "/guilds/#{guild.to_param}/breweries"

          expect(last_response.body).to eq('[]')
        end

        it 'returns breweries as JSON' do
          guild.breweries << Factory(:brewery)
          body = BreweryPresenter.present(guild.breweries.reload, context: context)

          get "/guilds/#{guild.to_param}/breweries"
          expect(last_response.body).to eq(body.to_json)
        end
      end
    end
  end
end
