require 'test_helper'

Temping.create :dummy do
  with_columns do |t|
    t.string :name
    t.string :permalink

    t.index :permalink, unique: true
  end

  include Permalinkable
end

class PermalinkableTest < ActiveSupport::TestCase
  before :each do
    @dummy = Dummy.create(name: 'dummy')
  end

  it 'validates the uniqueness of permalinks' do
    another_dummy = Dummy.new(name: 'dummy', permalink: 'dummy')
    another_dummy.wont_be :valid?
  end

  it 'overrides #to_param to return the permalink' do
    @dummy.to_param.must_equal @dummy.permalink
  end

  it 'adds a from_param scope to find records by permalink' do
    Dummy.from_param(@dummy.permalink).must_equal @dummy
  end

  context 'permalink generation' do
    it 'happens before creation' do
      dummy = Dummy.new(name: 'dummy')
      dummy.permalink.must_be_nil
      dummy.save
      dummy.permalink.wont_be_nil
    end

    it 'will append digits to make unique permalinks' do
      another_dummy = Dummy.create(name: 'dummy')
      another_dummy.permalink.must_equal 'dummy-2'

      yet_another_dummy = Dummy.create(name: 'dummy')
      yet_another_dummy.permalink.must_equal 'dummy-3'
    end
  end

  after :each do
    Dummy.destroy_all
  end
end
