require 'app/apis/base_api'
require 'app/models/user'

class AuthorizationsAPI < BaseAPI
  post do
    params.require(:login) and params.require(:password)

    user = User.from_login(params[:login])

    if user && user.authenticate(params[:password])
      user.generate_auth_token
    else
      unauthorized! 'Invalid credentials.'
    end
  end

  delete do
    unauthorized! unless authorized?

    AuthToken.find_by(token: auth_token).destroy
    head :no_content
  end
end
