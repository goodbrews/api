require 'app/models/user'

module AuthorizationHelper
  def current_user
    return @current_user if defined?(@current_user)

    header = request.headers['Authorization']

    # Authorization: token AUTH_TOKEN
    token = if header.present?
              header_type, header_value = header.split
              header_value if header_type =~ /\Atoken\z/i
            end

    @current_user = User.find_by(auth_token: token)
  end

  def authorized?
    !!current_user
  end
end
