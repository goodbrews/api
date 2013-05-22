require 'test_helper'

describe Api::V1::BreweryDB::WebhooksController do
  %w[beer brewery location guild event].each do |action|
    describe "##{action}" do
      before :each do
        # Set up the request.
        @body =  { action: 'insert', attributeId: 'hELlo', subAction: 'something-insert' }.to_json
        @options = { action: 'insert', id: 'hELlo', sub_action: 'something_insert' }
      end

      it 'must respond with a 200 if the key and nonce match' do
        nonce = SecureRandom.base64
        key = Digest::SHA1.hexdigest("#{ENV['BREWERY_DB_API_KEY']}#{nonce}")
        WebhookWorker.any_instance.expects(:perform_async).with(action, @options)

        raw_post action, { nonce: nonce, key: key }, @body
        response.must_be :success?
      end

      it 'must respond with a 401 if the key and nonce do not match' do
        raw_post action, { nonce: 'lol', key: 'nope' }, @body
        response.status.must_equal 401
      end
    end
  end
end
