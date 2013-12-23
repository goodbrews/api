require 'spec_helper'
require 'models/shared_examples/join_records'
require 'models/shared_examples/socialable'

describe Event do
  it_behaves_like 'a socialable'
  it_behaves_like 'something that has join records'

  describe '#to_param' do
    it 'returns the brewerydb_id' do
      event = Factory.build(:event)
      expect(event.to_param).to eq(event.brewerydb_id)
    end
  end

  describe '.from_param' do
    it 'raises an ActiveRecord::RecordNotFound if no event exists' do
      expect { Event.from_param('no') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'takes a brewerydb_id to find an Event using .from_param' do
      event = Factory(:event)
      expect(Event.from_param(event.brewerydb_id)).to eq(event)
    end
  end
end
