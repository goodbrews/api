require 'test_helper'

describe Brewery do
  it 'must be sluggable' do
    Brewery.ancestors.must_include Sluggable
  end

  context 'before destruction' do
    before :each do
      @brewery = Factory(:brewery)
    end

    it 'must clear Beer join records' do
      beer = Factory(:beer)
      beer.breweries << @brewery

      beer.reload and @brewery.reload

      @brewery.destroy
      beer.reload

      beer.id.wont_be_nil
      beer.breweries.wont_include(@brewery)
    end

    it 'must clear Event join records' do
      event = Factory(:event)
      event.breweries << @brewery

      event.reload and @brewery.reload

      @brewery.destroy
      event.reload

      event.id.wont_be_nil
      event.breweries.wont_include(@brewery)
    end

    it 'must clear Guild join records' do
      guild = Factory(:guild)
      guild.breweries << @brewery

      guild.reload and @brewery.reload

      @brewery.destroy
      guild.reload

      guild.id.wont_be_nil
      guild.breweries.wont_include(@brewery)
    end

    it 'must destroy locations' do
      location = Factory(:location, brewery: @brewery)
      @brewery.destroy

      lambda { location.reload }.must_raise(ActiveRecord::RecordNotFound)
    end
  end
end
