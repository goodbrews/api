class SocialMediaAccount < ActiveRecord::Base
  belongs_to :socialable, polymorphic: true

  def url
    self.send("#{website.parameterize('_')}_url")
  end

  private
    def facebook_fan_page_url
      "http://www.facebook.com/#{handle}"
    end
    alias :facebook_profile_url :facebook_fan_page_url

    def twitter_url
      "http://twitter.com/#{handle}"
    end

    def foursquare_url
      "http://foursquare.com/v/#{handle}"
    end

    def untappd_url
      "http://untappd.com/#{socialable_type.downcase}/#{handle}"
    end

    def ratebeer_url
      type = (socialable_type == 'Brewery' ? 'brewers' : 'beer')
      "http://www.ratebeer.com/#{type}/#{handle}"
    end

    def beeradvocate_url
      "http://www.beeradvocate.com/beer/profile/#{handle}"
    end

    def google_plus_url
      "https://plus.google.com/#{handle}"
    end

    def flickr_url
      "http://www.flickr.com/photos/#{handle}"
    end

    def youtube_url
      "http://www.youtube.com/#{handle}"
    end

    def instagram_url
      "http://instagram.com/#{handle}"
    end

    def yelp_url
      "http://yelp.com/#{handle}"
    end

    def pinterest_url
      "http://pinterest.com/#{handle}"
    end

    def linkedin_url
      "http://linkedin.com/in/#{handle}"
    end

    def feed_url
      handle
    end
end
