require 'app/models/auth_token'

module Authenticatable
  extend ActiveSupport::Concern

  included do
    has_secure_password
    attr_accessor :current_password

    has_many :auth_tokens
    after_create :generate_auth_token

    validates :password, length: {
                           minimum: 8,
                           maximum: 50,
                           message: 'must be between 8 and 50 characters',
                           allow_blank: true
                         }
  end

  def generate_auth_token
    auth_tokens.create!
  end

  def update_with_password(params, *options)
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = if authenticate(current_password)
      update_attributes(params, *options)
    else
      self.assign_attributes(params, *options)
      self.valid?
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end

    self.password = self.password_confirmation = nil
    result
  end

  def send_password_reset
    generate_password_reset

    erb = ERB.new(File.read('app/templates/reset_password.html.erb'))

    mail = Mail.new do
      content_type 'text/html; charset=UTF-8'
      from    'brewmaster@goodbre.ws'
      subject 'Reset your goodbre.ws password'
    end

    mail[:to]   = self.email
    mail[:body] = erb.result(self.instance_eval { binding })

    mail.deliver!
  end

  private

    def generate_password_reset
      begin
        self.password_reset_token = SecureRandom.hex
      end while User.exists?(password_reset_token: self.password_reset_token)

      self.password_reset_sent_at = Time.zone.now
      save!
    end
end
