require 'spec_helper'
require 'app/apis/api'

describe WebhooksAPI do
  def app
    Goodbrews::API
  end

  context 'with an invalid key/nonce pair' do
    before do
      params = {
        key: Digest::SHA1.hexdigest("#{ENV['BREWERY_DB_API_KEY']}hello"),
        nonce: 'goodbye',
        action: 'insert',
        attributeId: 'test'
      }

      post '/brewery_db/webhooks/beer', params
    end

    it 'returns a 401 status' do
      expect(last_response.status).to eq(401)
    end

    it 'reports that the key and nonce do not match up' do
      expect(last_response.body).to include('Nonce/key pair mismatch.')
    end
  end

  context 'with a valid key/nonce pair' do
    let(:params) do
      {
        key: Digest::SHA1.hexdigest("#{ENV['BREWERY_DB_API_KEY']}hello"),
        nonce: 'hello',
        action: 'insert',
        attributeId: 'test'
      }
    end

    it 'initializes a WebhookWorker with the params and returns a 202' do
      expect(WebhookWorker).to receive(:perform_async)

      post '/brewery_db/webhooks/beer', params

      expect(last_response.status).to eq(202)
    end
  end
end
