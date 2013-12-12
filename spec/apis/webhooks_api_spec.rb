require 'spec_helper'
require 'app/apis/api'

describe WebhooksAPI do
  def app
    Goodbrews::API
  end

  context 'without required params' do
    before do
      post '/brewery_db/webhooks/beer'
    end

    it 'returns a 400 status' do
      expect(last_response.status).to eq(400)
    end

    it 'requires a key/nonce pair' do
      expect(last_response.body).to include('key is missing')
      expect(last_response.body).to include('nonce is missing')
    end

    it 'requires actionable params sent by BreweryDB' do
      expect(last_response.body).to include('action is missing')
      expect(last_response.body).to include('attributeId is missing')
    end
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

    it 'returns a 400 status' do
      expect(last_response.status).to eq(400)
    end

    it 'reports that the key and nonce do not match up' do
      expect(last_response.body).to include('key does not match our BreweryDB API key')
      expect(last_response.body).not_to include('key is missing')
      expect(last_response.body).not_to include('nonce is missing')
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

    it 'initializes a WebhookWorker with the params' do
      expect(WebhookWorker).to receive(:perform_async)

      post '/brewery_db/webhooks/beer', params

      expect(last_response.status).to eq(200)
    end
  end
end
