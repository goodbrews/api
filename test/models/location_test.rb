require 'test_helper'

describe Location do
  it 'must be valid' do
    location = Factory(:location)
    location.must_be :valid?
  end
end
