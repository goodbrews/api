require Grape.root.join('app/models/concerns/authenticatable')

class User < ActiveRecord::Base
  include Authenticatable

  before_create { generate_token(:auth_token) }

  validates :username, exclusion: {
                         in: %w(admin goodbrews),
                         message: 'is reserved'
                       },
                       uniqueness: {
                         case_sensitive: false,
                         message: 'has already been taken'
                       },
                       format: {
                         with: /\A\w+\z/,
                         message: "can only contain letters, numbers, or '_'.",
                         allow_blank: true
                       },
                       length: {
                         maximum: 40,
                         allow_blank: true
                       },
                       presence: true

  validates :email, format: {
                      with: /.+@.+\..+/,
                      allow_blank: true
                     },
                     uniqueness: {
                      case_sensitive: false,
                      message: 'is already in use'
                     },
                     presence: true

  def to_param
    username
  end

  private

    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end
end
