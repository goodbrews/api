require "test_helper"

describe Brewery do
  before do
    @brewery = Brewery.new
  end

  it "must be valid" do
    @brewery.valid?.must_equal true
  end
end
