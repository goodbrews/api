class User < ActiveRecord::Base
  has_secure_password

  before_create { generate_token(:auth_token) }

  validates :password, length: {
                         minimum: 6,
                         on: :create,
                         message: 'must be longer than 6 characters'
                       }

  validates :password_confirmation, presence: { if: -> { password_digest_changed? }}

  validates :username, exclusion: {
                         in: %w(admin goodbrews guest),
                         message: 'is reserved'
                       },
                       format: {
                         with: /\A\w+\z/,
                         message: "can only contain letters, numbers, or '_'.",
                         allow_blank: true
                       },
                       uniqueness: {
                         case_sensitive: false,
                         message: 'has already been taken'
                       },
                       length: {
                         within: 1..40,
                         allow_blank: true
                       },
                       presence: true

  validates :email, format: {
                      with: /.+@.+/,
                      allow_blank: true
                     },
                    uniqueness: {
                      case_sensitive: false,
                      message: 'is already in use'
                    },
                    presence: true

  private
    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end
end
