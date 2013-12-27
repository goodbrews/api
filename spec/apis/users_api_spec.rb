require 'spec_helper'
require 'app/apis/api'

describe UsersAPI do
  def app
    Goodbrews::API
  end

  let(:context) do
    double.tap do |d|
      allow(d).to receive(:authorized?).and_return(false)
    end
  end

  context '/users' do
    context 'POST without valid params' do
      it 'returns 422' do
        body = {
          error: {
            message: [
              "Password can't be blank",
              "Username can't be blank",
              "Email can't be blank"
            ]
          }
        }

        post '/users'

        expect(last_response.status).to eq(422)
        expect(last_response.body).to eq(body.to_json)
      end
    end

    context 'POST with valid params' do
      it 'creates a user, returning its auth_token as JSON' do
        params = {
          username: 'user',
          email: 'user@goodbre.ws',
          password: 'supersecret',
          password_confirmation: 'supersecret'
        }

        post '/users', params

        expect(last_response.status).to eq(201)
        expect(User.count).to eq(1)
        expect(last_response.body).to eq(%({"auth_token":"#{User.first.auth_token}"}))
      end
    end

    context '/:username' do
      context 'without an existing user' do
        it 'returns a 404' do
          get '/users/nothing-here'

          expect(last_response.status).to eq(404)
        end
      end

      context 'with an existing user' do
        let(:user) { Factory(:user) }
        before { allow(context).to receive(:current_user).and_return(nil) }

        it 'returns an existing user as json' do
          body = UserPresenter.present(user, context: context)

          get "/users/#{user.to_param}"

          expect(last_response.body).to eq(body.to_json)
        end

        context 'on PUT' do
          it 'returns 401 if the user is unauthorized' do
            put "/users/#{user.to_param}", { username: user.username }, 'HTTP_AUTHORIZATION' => "token #{user.auth_token * 2}"

            expect(last_response.status).to eq(401)
            expect(last_response.body).to eq('{"error":{"message":"Unauthorized"}}')
          end

          it 'requires a current_password' do
            put "/users/#{user.to_param}", { username: user.username }, 'HTTP_AUTHORIZATION' => "token #{user.auth_token}"

            expect(last_response.status).to eq(422)
            expect(last_response.body).to include("Current password is required")
          end

          it 'updates a user with valid params' do
            params = {
              username:              'fantastic-user',
              email:                 'fantastic.user@goodbre.ws',
              current_password:      'supersecret',
              password:              'notsecret',
              password_confirmation: 'notsecret'
            }

            put "/users/#{user.to_param}", params, 'HTTP_AUTHORIZATION' => "token #{user.auth_token}"

            expect(last_response.status).to eq(204)
          end
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
            before do
              allow(context).to receive(:authorized?).and_return(true)
              allow(context).to receive(:current_user).and_return(user)
            end

            it 'returns an empty array' do
              get "/users/#{user.to_param}/hidden", {}, 'HTTP_AUTHORIZATION' => "token #{user.auth_token}"

              expect(last_response.body).to eq('[]')
            end

            it 'returns beers as JSON' do
              beer = Factory(:beer)
              user.hide(beer)
              beers = user.hidden_beers.includes(:ingredients, :social_media_accounts, :style)

              body = BeerPresenter.present(beers, context: context)

              get "/users/#{user.to_param}/hidden", {}, 'HTTP_AUTHORIZATION' => "token #{user.auth_token}"
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
end
