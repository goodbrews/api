require 'app/models/social_media_account'
require 'app/presenters/paginated_presenter'

class SocialMediaAccountPresenter < Jsonite
  properties :website, :handle

  link(:external) { url }
end

class SocialMediaAccountsPresenter < PaginatedPresenter
  property(:social_media_accounts, with: SocialMediaAccountPresenter) { to_a }
end
