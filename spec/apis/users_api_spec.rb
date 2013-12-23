require 'spec_helper'
require 'app/apis/users_api'

describe UsersAPI do
  def app
    Goodbrews::API
  end

  context '/users/:username' do
    context 'without an existing user' do
      it 'returns a 404' do
        get '/users/nothing-here'

        expect(last_response.status).to eq(404)
      end
    end

    context 'with an existing user' do
      let(:user) { Factory(:user) }
      let(:context) do
        double.tap do |d|
          allow(d).to receive(:current_user).and_return(nil)
        end
      end

      it 'returns an existing user as json' do
        body = UserPresenter.present(user, context: context)

        get "/users/#{user.to_param}"

        expect(last_response.body).to eq(body.to_json)
      end

      context '/likes' do
        it 'returns an empty array' do
          get "/users/#{user.to_param}/likes"

          expect(last_response.body).to eq('[]')
        end

        it 'returns beers as JSON' do
          beer = Factory(:beer)
          user.like(beer)
          beers = user.liked_beers.includes(:ingredients, :social_media_accounts, :style)

          body = BeerPresenter.present(beers, context: context)

          get "/users/#{user.to_param}/likes"
          expect(last_response.body).to eq(body.to_json)
        end
      end

      context '/dislikes' do
        it 'returns an empty array' do
          get "/users/#{user.to_param}/dislikes"

          expect(last_response.body).to eq('[]')
        end

        it 'returns beers as JSON' do
          beer = Factory(:beer)
          user.dislike(beer)
          beers = user.disliked_beers.includes(:ingredients, :social_media_accounts, :style)

          body = BeerPresenter.present(beers, context: context)

          get "/users/#{user.to_param}/dislikes"
          expect(last_response.body).to eq(body.to_json)
        end
      end

      context '/cellar' do
        it 'returns an empty array' do
          get "/users/#{user.to_param}/cellar"

          expect(last_response.body).to eq('[]')
        end

        it 'returns beers as JSON' do
          beer = Factory(:beer)
          user.bookmark(beer)
          beers = user.bookmarked_beers.includes(:ingredients, :social_media_accounts, :style)

          body = BeerPresenter.present(beers, context: context)

          get "/users/#{user.to_param}/cellar"
          expect(last_response.body).to eq(body.to_json)
        end
      end

      context '/hidden' do
        context 'when unauthorized' do
          it 'returns a 403' do
            get "/users/#{user.to_param}/hidden"

            expect(last_response.status).to eq(401)
            expect(last_response.body).to eq('{"error":{"message":"Unauthorized"}}')
          end
        end

        context 'when authorized' do
          let(:context) do
            double.tap do |d|
              allow(d).to receive(:current_user).and_return(user)
            end
          end

          it 'returns an empty array' do
            get "/users/#{user.to_param}/hidden", auth_token: user.auth_token

            expect(last_response.body).to eq('[]')
          end

          it 'returns beers as JSON' do
            beer = Factory(:beer)
            user.hide(beer)
            beers = user.hidden_beers.includes(:ingredients, :social_media_accounts, :style)

            body = BeerPresenter.present(beers, context: context)

            get "/users/#{user.to_param}/hidden", auth_token: user.auth_token
            expect(last_response.body).to eq(body.to_json)
          end
        end
      end

      context '/similar' do
        it 'returns an empty array' do
          get "/users/#{user.to_param}/similar"

          expect(last_response.body).to eq('[]')
        end

        it 'returns users as JSON' do
          friend = Factory(:user)
          expect(user).to receive(:similar_raters).and_return([friend])
          expect(User).to receive(:from_param).with(user.username).and_return(user)

          body = UserPresenter.present([friend], context: context)

          get "/users/#{user.to_param}/similar"
          expect(last_response.body).to eq(body.to_json)
        end
      end
    end
  end
end
