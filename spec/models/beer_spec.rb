require 'spec_helper'
require 'app/models/beer'
require 'spec/models/shared_examples/join_records'
require 'spec/models/shared_examples/sluggable'
require 'spec/models/shared_examples/socialable'

describe Beer do
  it_behaves_like 'something that has join records'
  it_behaves_like 'a sluggable'
  it_behaves_like 'a socialable'
end
