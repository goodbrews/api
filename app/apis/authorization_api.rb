require 'app/apis/base_api'
require 'app/models/user'

class AuthorizationAPI < BaseAPI
  rescue_from(Crepe::Params::Missing) do |e|
    unauthorized! e.message
  end

  # TODO: Filter the password parameter from login.
  post :authorize do
    params.require(:login) and params.require(:password)

    user = User.from_login(params[:login])

    if user && user.authenticate(params[:password])
      { auth_token: user.auth_token }
    else
      unauthorized! 'Invalid credentials.'
    end
  end
end
