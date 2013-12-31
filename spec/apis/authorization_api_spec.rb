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

  context 'POST /authorize' do
    let(:user) { Factory(:user) }

    it 'requires a login' do
      post '/authorize'

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq('{"error":{"message":"Missing parameter: login","missing":"login"}}')
    end

    it 'requires a password' do
      post '/authorize', login: user.username

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq('{"error":{"message":"Missing parameter: password","missing":"password"}}')
    end

    it 'returns a 401 with bad credentials' do
      post '/authorize', login: user.username, password: user.username

      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq('{"error":{"message":"Invalid credentials."}}')
    end

    it 'accepts a username as login' do
      post '/authorize', login: user.username, password: 'supersecret'

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq(%({"auth_token":"#{user.auth_token}"}))
    end

    it 'accepts an email address as login' do
      post '/authorize', login: user.email, password: 'supersecret'

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq(%({"auth_token":"#{user.auth_token}"}))
    end
  end
end
