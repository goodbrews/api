require "test_helper"

describe Event do
  context 'before destruction' do
    before do
      @event = Factory(:event)
    end

    it 'must be socialable' do
      Event.ancestors.must_include Socialable
    end

    it 'must clear Beer join records' do
      beer = Factory(:beer)
      beer.events << @event

      beer.reload and @event.reload

      @event.destroy
      beer.reload

      beer.id.wont_be_nil
      beer.events.wont_include(@event)
    end

    it 'must clear Brewery join records' do
      brewery = Factory(:brewery)
      brewery.events << @event

      brewery.reload and @event.reload

      @event.destroy
      brewery.reload

      brewery.id.wont_be_nil
      brewery.events.wont_include(@event)
    end
  end
end
