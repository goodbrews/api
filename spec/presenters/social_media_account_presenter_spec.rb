require 'spec_helper'
require 'app/presenters/social_media_account_presenter'

describe SocialMediaAccountPresenter do
  let(:social_media_accounts) do
    [Factory(:social_media_account), Factory(:social_media_account)]
  end

  it 'presents a social_media_account with a root key' do
    social_media_account = social_media_accounts.first

    expected = {
      'social_media_account' => {
        'website' => social_media_account.website,
        'handle'  => social_media_account.handle,

        '_links' => {
          'external' => {
            'href' => social_media_account.url
          }
        }
      }
    }

    hash = SocialMediaAccountPresenter.present(social_media_accounts.first, context: self)

    expect(hash).to eq(expected)
  end

  it 'presents an array of social_media_accounts without root keys' do
    expected = [
      SocialMediaAccountPresenter.present(social_media_accounts.first, context: self)['social_media_account'],
      SocialMediaAccountPresenter.present(social_media_accounts.last,  context: self)['social_media_account']
    ]

    expect(SocialMediaAccountPresenter.present(social_media_accounts, context: self)).to eq(expected)
  end
end
