require 'test_helper'

describe Beer do
  it 'must be sluggable' do
    Beer.ancestors.must_include Sluggable
  end

  context 'before destruction' do
    before :each do
      @beer = Factory(:beer)
    end

    it 'must clear Brewery join records' do
      brewery = Factory(:brewery)
      brewery.beers << @beer

      @beer.reload and brewery.reload

      @beer.destroy
      brewery.reload

      brewery.id.wont_be_nil
      brewery.beers.wont_include(@beer)
    end

    it 'must clear Ingredient join records' do
      ingredient = Factory(:ingredient)
      ingredient.beers << @beer

      @beer.reload and ingredient.reload

      @beer.destroy
      ingredient.reload

      ingredient.id.wont_be_nil
      ingredient.beers.wont_include(@beer)
    end

    it 'must clear Event join records' do
      event = Factory(:event)
      event.beers << @beer

      @beer.reload and event.reload

      @beer.destroy
      event.reload

      event.id.wont_be_nil
      event.beers.wont_include(@beer)
    end
  end
end
