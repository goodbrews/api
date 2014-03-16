require 'securerandom'
require 'app/models/user'

class AuthToken < ActiveRecord::Base
  belongs_to :user

  before_create :generate_token

  def to_s
    self.token
  end

  def to_json(options = {})
    { auth_token: self.to_s }.to_json
  end

  private

    def generate_token
      begin
        self.token = SecureRandom.hex
      end while AuthToken.exists?(token: self.token)
    end
end
