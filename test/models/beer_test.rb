require 'test_helper'

describe Beer do
  before do
    @beer = Beer.new
  end

  it 'must be sluggable' do
    Beer.ancestors.must_include Sluggable
  end
end
