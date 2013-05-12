require 'test_helper'

describe Brewery do
  it 'must be sluggable' do
    Brewery.ancestors.must_include Sluggable
  end

  it 'must clear Beer join records before destruction' do
    @brewery = Factory(:brewery)
    @beer = Factory(:beer)
    @beer.breweries << @brewery

    @beer.reload and @brewery.reload

    @brewery.destroy
    @beer.reload

    @beer.id.wont_be_nil
    @beer.breweries.wont_include(@brewery)
  end
end
