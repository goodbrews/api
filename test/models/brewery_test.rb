require 'test_helper'

describe Brewery do
  before :each do
    @brewery = Factory(:brewery)
  end

  it 'must be sluggable' do
    Brewery.ancestors.must_include Sluggable
  end

  it 'must clear Beer join records before destruction' do
    @beer = Factory(:beer)
    @beer.breweries << @brewery

    @beer.reload and @brewery.reload

    @brewery.destroy
    @beer.reload

    @beer.id.wont_be_nil
    @beer.breweries.wont_include(@brewery)
  end

  it 'must destroy locations along with itself' do
    location = Factory(:location, brewery: @brewery)
    @brewery.destroy

    lambda { location.reload }.must_raise(ActiveRecord::RecordNotFound)
  end
end
