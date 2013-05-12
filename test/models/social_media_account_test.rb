require 'test_helper'

describe SocialMediaAccount do
  before do
    @social_media_account = Factory(:social_media_account)
  end

  it 'must be valid' do
    @social_media_account.valid?.must_equal true
  end
end
