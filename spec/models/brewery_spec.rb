require 'spec_helper'
require 'app/models/brewery'
require 'spec/models/shared_examples/join_records'

describe Brewery do
  it_behaves_like 'something that has join records'
end
