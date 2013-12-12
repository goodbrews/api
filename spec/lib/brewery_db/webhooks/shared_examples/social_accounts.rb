shared_examples 'a webhook that updates social accounts' do
  let(:klass)         { described_class.to_s.demodulize.underscore }
  let(:cassette)      { "#{klass}_social_media_accounts" }
  let(:webhook_klass) { described_class }
  let!(:model)        { Factory(klass, brewerydb_id: model_id) }

  context '#socialaccount_insert' do
    let(:webhook)  { webhook_klass.new(id: model_id, action: 'edit', sub_action: 'socialaccount_insert') }

    before { VCR.use_cassette(cassette) { webhook.process } }

    it 'creates and assigns social_media_accounts' do
      expect(model.social_media_accounts.count).to eq(response.count)
    end
  end

  context '#socialaccount_delete' do
    let(:webhook)  { webhook_klass.new(id: model_id, action: 'edit', sub_action: 'socialaccount_delete') }

    it 'destroys social_media_accounts' do
      accounts = response.map { |a| Factory(:social_media_account, website: a['name'], socialable: model) }
      account  = Factory(:social_media_account, website: 'BeerAdvocate', socialable: model)

      VCR.use_cassette(cassette) { webhook.process }

      expect { account.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

