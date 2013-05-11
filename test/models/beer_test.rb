require "test_helper"

describe Beer do
  before do
    @beer = Beer.new
  end

  it "must be valid" do
    @beer.valid?.must_equal true
  end
end
