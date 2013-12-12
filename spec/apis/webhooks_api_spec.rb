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
      last_response.status.should eq(400)
    end

    it 'requires a key/nonce pair' do
      last_response.body.should include('key is missing')
      last_response.body.should include('nonce is missing')
    end

    it 'requires actionable params sent by BreweryDB' do
      last_response.body.should include('action is missing')
      last_response.body.should include('attributeId is missing')
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
      last_response.status.should eq(400)
    end

    it 'reports that the key and nonce do not match up' do
      last_response.body.should include('key does not match our BreweryDB API key')
      last_response.body.should_not include('key is missing')
      last_response.body.should_not include('nonce is missing')
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
      WebhookWorker.should_receive(:perform_async)

      post '/brewery_db/webhooks/beer', params

      last_response.status.should eq(200)
    end
  end
end
