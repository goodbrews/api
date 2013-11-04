class SocialMediaAccount < ActiveRecord::Base
  belongs_to :socialable, polymorphic: true

  def url
    self.send("#{website.downcase}_url")
  end

  private
    def facebook_url
      "http://www.facebook.com/#{handle}" if socialable_type == 'Brewery'
    end

    def twitter_url
      "http://twitter.com/#{handle}" if socialable_type == 'Brewery'
    end

    def foursquare_url
      "http://foursquare.com/v/#{handle}" if socialable_type == 'Brewery'
    end

    def untappd_url
      "http://untappd.com/#{socialable_type.downcase}/#{handle}"
    end

    def ratebeer_url
      type = (socialable_type == 'Brewery' ? 'brewers' : 'beer')
      "http://www.ratebeer.com/#{type}/#{socialable.slug}/#{handle}"
    end

    def beeradvocate_url
      "http://www.beeradvocate.com/beer/profile/#{handle}" if socialable_type == 'Brewery'
    end
end
