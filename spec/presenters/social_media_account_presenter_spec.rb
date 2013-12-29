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
end

describe SocialMediaAccountsPresenter do
  let(:context) do
    double.tap do |d|
      allow(d).to receive(:params).and_return({})
    end
  end

  before { 2.times { Factory(:social_media_account) } }

  it 'presents a collection of social_media_accounts' do
    social_media_accounts = SocialMediaAccount.all
    expected = {
      'count' => 2,
      'social_media_accounts' => [
        SocialMediaAccountPresenter.new(social_media_accounts.first, context: context, root: nil).present,
        SocialMediaAccountPresenter.new(social_media_accounts.last,  context: context, root: nil).present
      ]
    }

    presented = SocialMediaAccountsPresenter.new(social_media_accounts, context: context, root: nil).present

    expect(presented).to eq(expected)
  end
end

