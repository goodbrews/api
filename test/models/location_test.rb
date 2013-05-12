require 'test_helper'

describe Location do
  it 'must be falid' do
    location = Factory(:location)
    location.must_be :valid?
  end
end
