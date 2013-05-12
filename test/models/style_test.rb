require 'test_helper'

describe Style do
  before do
    @style = Style.new
  end

  it 'must be sluggable' do
    Style.ancestors.must_include Sluggable
  end
end
