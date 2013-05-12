require 'test_helper'

class SocialableTest < ActiveSupport::TestCase
  context 'with a Brewery' do
    before :each do
      @brewery = Factory(:brewery)
      @account = Factory(:social_media_account, socialable: @brewery)
    end

    it 'must provide a Facebook URL' do
      @account.website = 'Facebook' and @account.save

      @brewery.facebook_url.must_equal "http://www.facebook.com/#{@account.handle}"
    end

    it 'must provide a Twitter URL' do
      @account.website = 'Twitter' and @account.save

      @brewery.twitter_url.must_equal "http://twitter.com/#{@account.handle}"
    end

    it 'must provide a Foursquare URL' do
      @account.website = 'Foursquare' and @account.save

      @brewery.foursquare_url.must_equal "http://foursquare.com/v/#{@account.handle}"
    end

    it 'must provide a Untappd URL' do
      @account.website = 'Untappd' and @account.save

      @brewery.untappd_url.must_equal "http://untappd.com/brewery/#{@account.handle}"
    end

    it 'must provide a RateBeer URL' do
      @account.website = 'RateBeer' and @account.save

      @brewery.ratebeer_url.must_equal "http://www.ratebeer.com/brewers/#{@brewery.slug}/#{@account.handle}/"
    end

    it 'must provide a BeerAdvocate URL' do
      @account.website = 'BeerAdvocate' and @account.save

      @brewery.beeradvocate_url.must_equal "http://www.beeradvocate.com/beer/profile/#{@account.handle}"
    end
  end

  context 'with a Beer' do
    before :each do
      @beer = Factory(:beer)
      @account = Factory(:social_media_account, socialable: @beer)
    end

    it 'must provide an Untappd URL' do
      @account.website = 'Untappd' and @account.save

      @beer.untappd_url.must_equal "http://untappd.com/beer/#{@account.handle}"
    end

    it 'must provide a RateBeer URL' do
      @account.website = 'RateBeer' and @account.save

      @beer.ratebeer_url.must_equal "http://www.ratebeer.com/beer/#{@beer.slug}/#{@account.handle}"
    end

    %w[Facebook Twitter FourSquare BeerAdvocate].each do |site|
      it "cannot provide a #{site} URL" do
        @beer.send("#{site.downcase}_url").must_be :blank?
      end
    end
  end
end
