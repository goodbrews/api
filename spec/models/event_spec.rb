require 'spec_helper'
require 'models/shared_examples/join_records'
require 'models/shared_examples/socialable'

describe Event do
  it_behaves_like 'a socialable'
  it_behaves_like 'something that has join records'
end
