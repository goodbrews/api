require 'spec_helper'
require 'app/models/brewery'
require 'spec/models/shared_examples/join_records'
require 'spec/models/shared_examples/socialable'

describe Brewery do
  it_behaves_like 'something that has join records'
  it_behaves_like 'a socialable'
end
