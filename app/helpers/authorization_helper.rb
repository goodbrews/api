require 'app/models/user'

module AuthorizationHelper
  def current_user
    return @current_user if defined?(@current_user)

    token = AuthToken.find_by(token: auth_token)
    @current_user = token.user if token
  end

  def authorized?
    !!current_user
  end

  def auth_token
    header = request.headers['Authorization']

    if header.present?
      header_type, header_value = header.split
      header_value if header_type =~ /\AAUTH-TOKEN\z/i
    end
  end
end
