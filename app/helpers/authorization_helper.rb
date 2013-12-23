require 'app/models/user'

module AuthorizationHelper
  def current_user
    @current_user ||= begin
      header = request.headers['Authorization']

      # Authorization: token AUTH_TOKEN
      token = if header.present?
                header_type, header_value = header.split
                header_value if header_type =~ /\Atoken\z/i
              else
                token = params[:auth_token]
              end

      User.find_by(auth_token: token)
    end
  end

  def authorized?
    !!current_user
  end
end
