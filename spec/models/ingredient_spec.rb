require 'spec_helper'
require 'app/models/ingredient'
require 'models/shared_examples/join_records'

describe Ingredient do
  it_behaves_like 'something that has join records'
end
