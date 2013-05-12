require 'test_helper'

describe Beer do
  it 'must be sluggable' do
    Beer.ancestors.must_include Sluggable
  end

  it 'must clear Brewery join records before destruction' do
    @beer = Factory(:beer)
    @brewery = Factory(:brewery)
    @brewery.beers << @beer

    @beer.reload and @brewery.reload

    @beer.destroy
    @brewery.reload

    @brewery.id.wont_be_nil
    @brewery.beers.wont_include(@beer)
  end
end
