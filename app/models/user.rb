require 'app/models/concerns/authenticatable'
require 'app/models/beer'

class User < ActiveRecord::Base
  include Authenticatable
  include PgSearch

  PERMISSIBLE_PARAMS = [
    :username,
    :email,
    :password,
    :password_confirmation,
    :name,
    :city,
    :region,
    :country
  ]

  after_create :send_welcome_email
  recommends :beers

  pg_search_scope :search, against: :username,
                           using: {
                             tsearch: {
                               prefix:     true,
                               any_word:   true,
                               dictionary: 'english'
                             },
                             trigram: {
                               threshold: 0.5
                             }
                           },
                           ignoring: :accents

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
                         with: /\A[\w\-]+\z/,
                         message: "can only contain letters, numbers, '-', or '_'.",
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

  def display_name
    name.presence || username
  end

  def self.from_login(login)
    find_by('lower(username) = lower(?) OR lower(email) = lower(?)', login, login)
  end

  private

    def send_welcome_email
      erb = ERB.new(File.read('app/templates/welcome.html.erb'))

      mail = Mail.new do
        content_type 'text/html; charset=UTF-8'
        from    'brewmaster@goodbre.ws'
        subject 'Welcome to goodbre.ws!'
      end

      mail[:to]   = self.email
      mail[:body] = erb.result(self.instance_eval { binding })

      mail.deliver!
    end
end
