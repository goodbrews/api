require 'app/models/user'

module AuthorizationHelper
  def current_user
    return @current_user if defined?(@current_user)

    header = request.headers['Authorization']

    token = if header.present?
      header_type, header_value = header.split
      header_value if header_type =~ /\AAUTH-TOKEN\z/i
    end

    auth_token = AuthToken.find_by(token: token)
    @current_user = auth_token.user if auth_token
  end

  def authorized?
    !!current_user
  end
end
