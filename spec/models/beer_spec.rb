require 'spec_helper'
require  'app/models/beer'
require  'spec/models/shared_examples/join_records'

describe Beer do
  it_behaves_like 'something that has join records'
end
