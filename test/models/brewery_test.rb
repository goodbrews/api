require 'test_helper'

describe Brewery do
  before do
    @brewery = Brewery.new
  end

  it 'must be sluggable' do
    Brewery.ancestors.must_include Sluggable
  end
end
