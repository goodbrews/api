require 'spec_helper'
require 'app/models/location'

describe Location do
  it 'must belong to a brewery' do
    location = Factory.build(:location, name: '', website: '', brewery: nil)
    location.should_not be_valid
    location.errors[:brewery].should include("can't be blank")

    location.brewery = Factory.build(:brewery)
    location.should be_valid
  end
end
