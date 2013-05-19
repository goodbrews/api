require 'test_helper'

describe Api::V1::BreweryDB::WebhooksController do
  %w[beer brewery location guild event].each do |action|
    describe "##{action}" do
      before :each do
        # Set up the request.
        nonce = SecureRandom.base64
        key = Digest::SHA1.hexdigest("#{ENV['BREWERY_DB_API_KEY']}#{nonce}")
        body =  { action: 'insert', attributeId: 'hELlo', subAction: 'something-insert' }.to_json
        options = { action: 'insert', id: 'hELlo', sub_action: 'something_insert' }

        # Stub out the HTTP request and Webhook processing functionality
        stub_request(:get, /.*api.brewerydb.com.*/)
        webhook = BreweryDB::Webhooks.const_get(action.classify)
        processor = webhook.new(options)
        webhook.expects(:new).with(options).once.returns(processor)
        webhook.any_instance.stubs(:process).returns(true)

        raw_post action, { nonce: nonce, key: key }, body
      end

      it { response.must_be :success? }
    end
  end
end
