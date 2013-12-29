require 'app/models/social_media_account'

class SocialMediaAccountPresenter < Jsonite
  properties :website, :handle

  link(:external) { url }
end

class SocialMediaAccountsPresenter < PaginatedPresenter
  property(:social_media_accounts, with: SocialMediaAccountPresenter) { to_a }
end
