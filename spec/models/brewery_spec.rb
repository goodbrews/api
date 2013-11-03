require 'spec_helper'
require Grape.root.join('app/models/brewery')
require Grape.root.join('spec/models/shared_examples/join_records')

describe Brewery do
  it_behaves_like 'something that has join records'
end
