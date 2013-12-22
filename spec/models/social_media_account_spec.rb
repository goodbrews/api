require 'spec_helper'
require 'app/models/social_media_account'

describe SocialMediaAccount do
  %w[brewery beer].each do |klass|
    context "for a #{klass}" do
      let(:account) do
        Factory.build(:social_media_account, socialable: Factory.build(klass))
      end

      ['Facebook Fan Page', 'Facebook Profile'].each do |type|
        it 'can have a Facebook profile URL' do
          account.website = type
          expect(account.url).to eq("http://www.facebook.com/#{account.handle}")
        end
      end

      it 'can have a Twitter URL' do
        account.website = 'Twitter'
        expect(account.url).to eq("http://twitter.com/#{account.handle}")
      end

      it 'can have a Foursquare URL' do
        account.website = 'Foursquare'
        expect(account.url).to eq("http://foursquare.com/v/#{account.handle}")
      end

      it 'can have an Untappd URL' do
        account.website = 'Untappd'
        type = account.socialable_type.downcase

        expect(account.url).to eq("http://untappd.com/#{type}/#{account.handle}")
      end

      it 'can have a RateBeer URL' do
        account.website = 'RateBeer'
        type = account.socialable_type == 'Brewery' ? 'brewers' : 'beer'
        expect(account.url).to eq("http://www.ratebeer.com/#{type}/#{account.handle}")
      end

      it 'can have a BeerAdvocate URL' do
        account.website = 'BeerAdvocate'
        expect(account.url).to eq("http://www.beeradvocate.com/beer/profile/#{account.handle}")
      end

      it 'can have a Google Plus URL' do
        account.website = 'Google Plus'
        expect(account.url).to eq("https://plus.google.com/#{account.handle}")
      end

      it 'can have a Flickr URL' do
        account.website = 'Flickr'
        expect(account.url).to eq("http://www.flickr.com/photos/#{account.handle}")
      end

      it 'can have a Youtube URL' do
        account.website = 'YouTube'
        expect(account.url).to eq("http://www.youtube.com/#{account.handle}")
      end

      it 'can have a Instagram URL' do
        account.website = 'Instagram'
        expect(account.url).to eq("http://instagram.com/#{account.handle}")
      end

      it 'can have a Yelp URL' do
        account.website = 'Yelp'
        expect(account.url).to eq("http://yelp.com/#{account.handle}")
      end

      it 'can have a Pinterest URL' do
        account.website = 'Pinterest'
        expect(account.url).to eq("http://pinterest.com/#{account.handle}")
      end

      it 'can have a feed URL' do
        account.website = 'Feed'
        expect(account.url).to eq(account.handle)
      end
    end
  end
end
