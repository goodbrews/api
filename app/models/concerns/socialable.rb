require 'app/models/social_media_account'

module Socialable
  extend ActiveSupport::Concern

  included do
    has_many :social_media_accounts, as: :socialable, dependent: :destroy
  end
end
