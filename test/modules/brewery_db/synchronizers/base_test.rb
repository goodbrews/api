require 'test_helper'

class BaseTest < ActiveSupport::TestCase
  before :each do
    @synchronizer = BreweryDB::Synchronizers::Base.new
    @response     = mock
    @synchronizer.stubs(:fetch).returns(@response)
  end

  context 'synchronize!' do
    it 'calls fetch to grab records' do
      @response.expects(:body).at_least_once.returns({ 'numberOfPages' => 1, 'data' => [] })

      @synchronizer.synchronize!
    end

    it 'calls fetch multiple times if there is more than one page' do
      number_of_pages = rand(10)
      @response.expects(:body).at_most(number_of_pages + 1).returns({ 'numberOfPages' => number_of_pages, 'data' => [] })

      @synchronizer.synchronize!
    end

    it 'calls update! on each object' do
      @response.expects(:body).twice.returns({ 'numberOfPages' => 1, 'data' => [1, 2, 3] })
      @synchronizer.expects(:update!).times(3).returns(true)

      @synchronizer.synchronize!
    end
  end

  context 'remove_deleted!' do
    it 'calls fetch with a "deleted" parameter to grab removed records' do
      @synchronizer.expects(:fetch).with(status: 'deleted').returns(@response)
      @response.expects(:body).at_least_once.returns({ 'numberOfPages' => 1, 'data' => [] })

      @synchronizer.remove_deleted!
    end

    it 'calls fetch multiple times if there is more than one page' do
      number_of_pages = rand(10)
      @response.expects(:body).at_most(number_of_pages + 1).returns({ 'numberOfPages' => number_of_pages, 'data' => [] })

      @synchronizer.remove_deleted!
    end

    it 'calls destroy! on each object' do
      @response.expects(:body).twice.returns({ 'numberOfPages' => 1, 'data' => [1, 2, 3] })
      @synchronizer.expects(:destroy!).times(3).returns(true)

      @synchronizer.remove_deleted!
    end
  end
end
