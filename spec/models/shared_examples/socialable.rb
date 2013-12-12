require 'app/models/social_media_account'

shared_examples 'a socialable' do
  let(:klass) { described_class.to_s.underscore.to_sym }
  let(:socialable) { Factory(klass) }
  let!(:account) { Factory(:social_media_account, socialable: socialable )}

  it 'must provide an object with a social_media_accounts association' do
    expect(socialable.social_media_accounts).not_to be_empty
  end

  it 'must destroy social media accounts on object destruction' do
    socialable.destroy
    expect { account.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
