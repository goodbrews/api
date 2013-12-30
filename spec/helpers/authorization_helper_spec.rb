require 'spec_helper'
require 'app/helpers/authorization_helper'

describe AuthorizationHelper do
  let(:app) do
    Class.new(Crepe::API) do
      helper AuthorizationHelper

      get :current_user do
        response = { authorized: authorized? }
        response[:current_user] = current_user.as_json if authorized?

        response
      end
    end
  end

  context 'without proper credentials' do
    it 'does not find a current_user' do
      get :current_user

      expect(last_response.body).to eq('{"authorized":false}')
    end
  end

  context 'with proper credentials' do
    let(:user)  { Factory(:user) }
    let(:token) { user.auth_token }
    let(:body)  { { authorized: true, current_user: user } }

    it 'should find a current user' do
      get :current_user, {}, 'HTTP_AUTHORIZATION' => "token #{token}"

      expect(last_response.body).to eq(body.to_json)
    end
  end
end
