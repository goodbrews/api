shared_examples 'a webhook that updates events' do
  let(:klass)         { described_class.to_s.demodulize.underscore }
  let(:cassette)      { "#{klass}_events" }
  let(:webhook_klass) { described_class }
  let!(:model)        { Factory(klass, brewerydb_id: model_id) }

  context '#event_insert' do
    let(:webhook) { webhook_klass.new(id: model_id, action: 'edit', sub_action: 'event_insert') }

    it 'raises an OrderingError if we do not have the events yet' do
      VCR.use_cassette(cassette) do
        expect { webhook.process }.to raise_error(BreweryDB::Webhook::OrderingError)
      end
    end

    it 'assigns events if we have them' do
      response.each { |e| Factory(:event, brewerydb_id: e['eventId']) }
      VCR.use_cassette(cassette) { webhook.process }
      model.events.count.should eq(response.count)
    end
  end

  context '#event_delete' do
    let(:webhook) { webhook_klass.new(id: model_id, action: 'edit', sub_action: 'event_delete') }

    it 'removes events from an association' do
      event = Factory(:event)
      events = response.map { |e| Factory(:event, brewerydb_id: e['eventId']) }
      events << event
      model.events = events

      VCR.use_cassette(cassette) { webhook.process }
      model.reload

      model.events.count.should eq(response.count)
      model.events.should_not include(event)
    end
  end

  context '#event_edit' do
    let(:webhook) { webhook_klass.new(id: model_id, action: 'edit', sub_action: 'event_edit') }

    it 'acts as a noop, returning true' do
      webhook.process.should be_true
    end
  end
end

