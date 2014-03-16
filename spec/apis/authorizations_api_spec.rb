require 'spec_helper'
require 'app/apis/api'

describe AuthorizationsAPI do
  def app
    Goodbrews::API
  end

  let(:context) do
    double.tap do |d|
      allow(d).to receive(:authorized?).and_return(false)
    end
  end

  context 'POST /authorizations' do
    let(:user) { Factory(:user) }
    let(:auth_token) { user.auth_tokens.last }

    it 'requires a login' do
      post '/authorizations'

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq('{"error":{"message":"Missing parameter: login","missing":"login"}}')
    end

    it 'requires a password' do
      post '/authorizations', login: user.username

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq('{"error":{"message":"Missing parameter: password","missing":"password"}}')
    end

    it 'returns a 401 with bad credentials' do
      post '/authorizations', login: user.username, password: user.username

      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq('{"error":{"message":"Invalid credentials."}}')
    end

    it 'accepts a username as login' do
      post '/authorizations', login: user.username, password: 'supersecret'

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq(auth_token.to_json)
    end

    it 'accepts an email address as login' do
      post '/authorizations', login: user.email, password: 'supersecret'

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq(auth_token.to_json)
    end

    it 'generates a new auth token for the user' do
      post '/authorizations', login: user.email, password: 'supersecret'
      user.reload

      expect(user.auth_tokens.count).to eq(2)
    end
  end

  context 'DELETE /authorizations' do
    let(:user) { Factory(:user) }
    let(:auth_token) { user.auth_tokens.last }

    it 'requires authorization' do
      delete '/authorizations'

      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq(%({"error":{"message":"Unauthorized"}}))
    end

    it 'removes the auth_token' do
      delete '/authorizations', {}, 'HTTP_AUTHORIZATION' => "AUTH-TOKEN #{auth_token}"

      expect(last_response.status).to eq(204)
      expect(user.reload.auth_tokens).to be_empty
    end
  end
end
