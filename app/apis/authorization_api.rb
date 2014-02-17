require 'app/apis/base_api'
require 'app/models/user'

class AuthorizationAPI < BaseAPI
  post :authorization do
    params.require(:login) and params.require(:password)

    user = User.from_login(params[:login])

    if user && user.authenticate(params[:password]) && user.authorize!
      { auth_token: user.auth_token }
    else
      unauthorized! 'Invalid credentials.'
    end
  end

  delete :authorization do
    unauthorized! unless authorized?

    current_user.update_attributes!(auth_token: nil)
    head :no_content
  end
end
