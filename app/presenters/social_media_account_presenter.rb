require 'app/models/social_media_account'

class SocialMediaAccountPresenter < Jsonite
  properties :website, :handle

  link(:external) { url }
end
