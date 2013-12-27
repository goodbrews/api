require 'app/models/concerns/authenticatable'
require 'app/models/beer'

class User < ActiveRecord::Base
  include Authenticatable

  PERMISSIBLE_PARAMS = [
    :username,
    :email,
    :password,
    :password_confirmation,
    :city,
    :region,
    :country
  ]

  before_create { generate_token(:auth_token) }
  recommends :beers

  # Alias the `bookmark` actions to `cellar` for recommendable
  alias_method :cellar,   :bookmark
  alias_method :uncellar, :unbookmark
  def cellared_beers() bookmarked_beers end

  scope :from_param, ->(param) { find_by!(username: param) }

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

  def self.from_login(login)
    User.find_by('lower(username) = lower(?) OR lower(email) = lower(?)', login, login)
  end

  private

    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end
end
