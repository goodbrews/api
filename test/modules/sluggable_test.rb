require 'test_helper'

Temping.create :dummy do
  include Sluggable

  with_columns do |t|
    t.string :name
    t.string :slug

    t.index :slug, unique: true
  end
end

class SluggableTest < ActiveSupport::TestCase
  context 'unscoped' do
    before :each do
      @dummy = Dummy.create(name: 'dummy')
    end

    it 'validates the uniqueness of slugs' do
      another_dummy = Dummy.new(name: 'dummy', slug: 'dummy')
      another_dummy.wont_be :valid?
    end

    it 'overrides #to_param to return the slug' do
      @dummy.to_param.must_equal @dummy.slug
    end

    it 'adds a from_param scope to find records by slug' do
      Dummy.from_param(@dummy.slug).must_equal @dummy
    end

    context 'slug generation' do
      it 'happens before creation' do
        dummy = Dummy.new(name: 'dummy')
        dummy.slug.must_be_nil
        dummy.save
        dummy.slug.wont_be_nil
      end

      it 'will append digits to make unique slugs' do
        another_dummy = Dummy.create(name: 'dummy')
        another_dummy.slug.must_equal 'dummy-2'

        yet_another_dummy = Dummy.create(name: 'dummy')
        yet_another_dummy.slug.must_equal 'dummy-3'
      end
    end

    after :each do
      Dummy.destroy_all
    end
  end
end
