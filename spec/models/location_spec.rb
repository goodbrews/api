require 'spec_helper'
require 'app/models/location'

describe Location do
  it 'must belong to a brewery' do
    location = Factory.build(:location, name: '', website: '', brewery: nil)
    expect(location).not_to be_valid
    expect(location.errors[:brewery]).to include("can't be blank")

    location.brewery = Factory.build(:brewery)
    expect(location).to be_valid
  end
end
