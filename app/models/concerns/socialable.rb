module Socialable
  extend ActiveSupport::Concern

  included do
    has_many :social_media_accounts, as: :socialable, dependent: :destroy
  end

  def facebook_url
    return '' if self.is_a?(Beer)
    account = social_media_accounts.find_by(website: 'Facebook')
    account ? "http://www.facebook.com/#{account.handle}" : ''
  end

  def twitter_url
    return '' if self.is_a?(Beer)
    account = social_media_accounts.find_by(website: 'Twitter')
    account ? "http://twitter.com/#{account.handle}" : ''
  end

  def foursquare_url
    return '' if self.is_a?(Beer)
    account = social_media_accounts.find_by(website: 'Foursquare')
    account ? "http://foursquare.com/v/#{account.handle}" : ''
  end

  def untappd_url
    account = social_media_accounts.find_by(website: 'Untappd')
    account ? "http://untappd.com/#{self.class.to_s.downcase}/#{account.handle}" : ''
  end

  def ratebeer_url
    account = social_media_accounts.find_by(website: 'RateBeer')
    return '' unless account

    case self
    when Beer
      "http://www.ratebeer.com/beer/#{self.slug}/#{account.handle}"
    when Brewery
      "http://www.ratebeer.com/brewers/#{self.slug}/#{account.handle}/"
    end
  end

  def beeradvocate_url
    # No BeerAdvocate URLs for beers yet
    return '' if self.is_a?(Beer)
    account = social_media_accounts.where(website: 'BeerAdvocate').first
    account ? "http://www.beeradvocate.com/beer/profile/#{account.handle}" : ''
  end
end
