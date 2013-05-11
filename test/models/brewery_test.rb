require "test_helper"

describe Brewery do
  before do
    @brewery = Brewery.new
  end

  it "must be permalinkable" do
    Brewery.ancestors.must_include Permalinkable
  end
end
