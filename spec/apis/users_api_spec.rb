require 'spec_helper'
require 'app/apis/api'

describe UsersAPI do
  def app
    Goodbrews::API
  end

  let(:context) do
    double.tap do |d|
      allow(d).to receive(:authorized?).and_return(false)
      allow(d).to receive(:params).and_return({})
    end
  end

  context '/users' do
    context 'POST without valid params' do
      it 'requires params to be wrapped in a `user` key' do
        post '/users'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq(%({"error":{"message":"Missing parameter: user","missing":"user"}}))
      end

      it 'disallows invalid parameters' do
        post '/users', { user: { nothing: :here } }

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq(%({"error":{"message":"Invalid parameter(s): nothing","invalid":["nothing"],"valid":["username","email","password","password_confirmation","name","city","region","country"]}}))
      end

      it 'requires certain parameters' do
        body = {
          error: {
            message: [
              "Password can't be blank",
              "Username can't be blank",
              "Email can't be blank"
            ]
          }
        }

        post '/users', { user: { country: 'USA' } }

        expect(last_response.status).to eq(422)
        expect(last_response.body).to eq(body.to_json)
      end
    end

    context 'POST with valid params' do
      it 'creates a user, returning its auth_token as JSON' do
        params = {
          user: {
            username: 'user',
            email: 'user@goodbre.ws',
            password: 'supersecret',
            password_confirmation: 'supersecret'
          }
        }

        post '/users', params

        expect(last_response.status).to eq(201)
        expect(User.count).to eq(1)
        expect(last_response.body).to eq(%({"auth_token":"#{User.first.auth_token}"}))
      end
    end

    context '/reset_password' do
      context 'POST without valid params' do
        it 'requires an email param' do
          post '/users/reset_password'

          expect(last_response.status).to eq(400)
          expect(last_response.body).to eq('{"error":{"message":"Missing parameter: email","missing":"email"}}')
        end
      end

      context 'POST with valid params' do
        let(:user) { Factory(:user) }

        it "resets a user's password" do
          expect(User).to receive(:find_by).with(email: user.email).and_return(user)
          expect(user).to receive(:send_password_reset)

          post '/users/reset_password', email: user.email

          expect(last_response.status).to eq(201)
          expect(last_response.body).to eq('{"message":"Email sent with password reset instructions."}')
        end

        it 'claims success even if no user is found' do
          post '/users/reset_password', email: 'nobody@here.com'

          expect(last_response.status).to eq(201)
          expect(last_response.body).to eq('{"message":"Email sent with password reset instructions."}')
        end
      end

      context '/:password_reset_token' do
        let(:user) { Factory(:user) }
        before { user.send_password_reset }

        context 'POST without valid params' do
          it 'requires a password' do
            post "/users/reset_password/#{user.password_reset_token}"

            expect(last_response.status).to eq(400)
            expect(last_response.body).to eq('{"error":{"message":"Missing parameter: password","missing":"password"}}')
          end

          it 'requires a password_confirmation' do
            post "/users/reset_password/#{user.password_reset_token}", password: 'imsosecret'

            expect(last_response.status).to eq(400)
            expect(last_response.body).to eq('{"error":{"message":"Missing parameter: password_confirmation","missing":"password_confirmation"}}')
          end

          it 'disallows other parameters' do
            post "/users/reset_password/#{user.password_reset_token}", password: 'imsosecret', password_confirmation: 'imsosecret', email: 'dont@let.me'

            expect(last_response.status).to eq(400)
            expect(last_response.body).to eq('{"error":{"message":"Invalid parameter(s): email","invalid":["email"],"valid":["password","password_confirmation","password_reset_token"]}}')
          end
        end

        context 'POST with valid params' do
          it "resets a user's password" do
            post "/users/reset_password/#{user.password_reset_token}", password: 'imsosecret', password_confirmation: 'imsosecret'

            expect(last_response.status).to eq(201)
            expect(last_response.body).to eq('{"message":"Your password has been reset."}')
            user.reload

            expect(user.authenticate('imsosecret')).to be_true
            expect(user.password_reset_token).to be_nil
          end
        end
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

          it 'requires parameters to be wrapped in a `user` key' do
            put "/users/#{user.to_param}", {}, 'HTTP_AUTHORIZATION' => "token #{user.auth_token}"

            expect(last_response.status).to eq(400)
            expect(last_response.body).to eq(%({"error":{"message":"Missing parameter: user","missing":"user"}}))
          end

          it 'requires a current_password' do
            put "/users/#{user.to_param}", { user: { username: 'fantastic-user' } }, 'HTTP_AUTHORIZATION' => "token #{user.auth_token}"

            expect(last_response.status).to eq(422)
            expect(last_response.body).to eq(%({"error":{"message":["Current password can't be blank"]}}))
          end

          it 'updates a user with valid params' do
            params = {
              user: {
                username:              'fantastic-user',
                email:                 'fantastic.user@goodbre.ws',
                current_password:      'supersecret',
                password:              'notsecret',
                password_confirmation: 'notsecret'
              }
            }

            put "/users/#{user.to_param}", params, 'HTTP_AUTHORIZATION' => "token #{user.auth_token}"

            expect(last_response.status).to eq(204)
          end
        end

        context '/likes' do
          it 'returns an empty array' do
            get "/users/#{user.to_param}/likes"

            expect(last_response.body).to eq('{"count":0,"beers":[]}')
          end

          it 'returns beers as JSON' do
            beer = Factory(:beer)
            user.like(beer)

            body = BeersPresenter.new(user.liked_beers, context: context, root: nil).present

            get "/users/#{user.to_param}/likes"
            expect(last_response.body).to eq(body.to_json)
          end
        end

        context '/dislikes' do
          it 'returns an empty array' do
            get "/users/#{user.to_param}/dislikes"

            expect(last_response.body).to eq('{"count":0,"beers":[]}')
          end

          it 'returns beers as JSON' do
            beer = Factory(:beer)
            user.dislike(beer)

            body = BeersPresenter.new(user.disliked_beers, context: context, root: nil).present

            get "/users/#{user.to_param}/dislikes"
            expect(last_response.body).to eq(body.to_json)
          end
        end

        context '/cellar' do
          it 'returns an empty array' do
            get "/users/#{user.to_param}/cellar"

            expect(last_response.body).to eq('{"count":0,"beers":[]}')
          end

          it 'returns beers as JSON' do
            beer = Factory(:beer)
            user.bookmark(beer)

            body = BeersPresenter.new(user.cellared_beers, context: context, root: nil).present

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

              expect(last_response.body).to eq('{"count":0,"beers":[]}')
            end

            it 'returns beers as JSON' do
              beer = Factory(:beer)
              user.hide(beer)

              body = BeersPresenter.new(user.hidden_beers, context: context, root: nil).present

              get "/users/#{user.to_param}/hidden", {}, 'HTTP_AUTHORIZATION' => "token #{user.auth_token}"
              expect(last_response.body).to eq(body.to_json)
            end
          end
        end

        context '/recommendations' do
          context 'when unauthorized' do
            it 'returns a 403' do
              get "/users/#{user.to_param}/recommendations"

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
              get "/users/#{user.to_param}/recommendations", {}, 'HTTP_AUTHORIZATION' => "token #{user.auth_token}"

              expect(last_response.body).to eq('{"count":0,"beers":[]}')
            end

            it 'returns beers as JSON' do
              # Coerce an ActiveRecord::Relation
              beer = Factory(:beer)
              beers = Beer.where(id: beer.id)

              expect(user).to receive(:recommended_beers).and_return(beers)
              expect(User).to receive(:from_param).with(user.to_param).and_return(user)

              body = BeersPresenter.new(beers, context: context, root: nil).present

              get "/users/#{user.to_param}/recommendations", {}, 'HTTP_AUTHORIZATION' => "token #{user.auth_token}"
              expect(last_response.body).to eq(body.to_json)
            end
          end
        end

        context '/similar' do
          it 'returns an empty array' do
            get "/users/#{user.to_param}/similar"

            expect(last_response.body).to eq('{"users":[]}')
          end

          it 'returns users as JSON' do
            friend = Factory(:user)
            expect(user).to receive(:similar_raters).twice.and_return([friend])
            expect(User).to receive(:from_param).with(user.username).and_return(user)

            body = UsersPresenter.new(user.similar_raters, context: context, root: nil)

            get "/users/#{user.to_param}/similar"
            expect(last_response.body).to eq(body.to_json)
          end
        end
      end
    end
  end
end
