require 'spec_helper'
require 'app/apis/api'

describe AuthorizationAPI do
  def app
    Goodbrews::API
  end

  let(:context) do
    double.tap do |d|
      allow(d).to receive(:authorized?).and_return(false)
    end
  end

  context 'POST /authorization' do
    let(:user) { Factory(:user, auth_token: nil) }

    it 'requires a login' do
      post '/authorization'

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq('{"error":{"message":"Missing parameter: login","missing":"login"}}')
    end

    it 'requires a password' do
      post '/authorization', login: user.username

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq('{"error":{"message":"Missing parameter: password","missing":"password"}}')
    end

    it 'returns a 401 with bad credentials' do
      post '/authorization', login: user.username, password: user.username

      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq('{"error":{"message":"Invalid credentials."}}')
    end

    it 'accepts a username as login' do
      post '/authorization', login: user.username, password: 'supersecret'

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq(%({"auth_token":"#{user.reload.auth_token}"}))
    end

    it 'accepts an email address as login' do
      post '/authorization', login: user.email, password: 'supersecret'

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq(%({"auth_token":"#{user.reload.auth_token}"}))
    end

    it 'generates a new auth token for the user' do
      post '/authorization', login: user.email, password: 'supersecret'
      old_auth_token = user.auth_token
      user.reload

      expect(user.auth_token).to be_present
      expect(user.auth_token).not_to eq(old_auth_token)
    end
  end

  context 'DELETE /authorization' do
    let(:user) { Factory(:user) }

    it 'requires authorization' do
      delete '/authorization'

      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq(%({"error":{"message":"Unauthorized"}}))
    end

    it 'removes the auth_token' do
      delete '/authorization', {}, 'HTTP_AUTHORIZATION' => "token #{user.auth_token}"

      expect(last_response.status).to eq(204)
      expect(user.reload.auth_token).to be_nil
    end
  end
end
