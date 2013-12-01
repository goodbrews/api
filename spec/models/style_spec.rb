require 'spec_helper'
require 'app/models/style'
require 'spec/models/shared_examples/sluggable'

describe Style do
  it_behaves_like 'a sluggable'
end
