class User < ActiveRecord::Base
  has_secure_password

  before_create { generate_token(:auth_token) }

  validates :password, length: {
                         minimum: 6,
                         on: :create,
                         message: 'must be longer than 6 characters'
                       }

  validates :password_confirmation, presence: { if: -> { password_digest_changed? }}

  private
    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end
end
