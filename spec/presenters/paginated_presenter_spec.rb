require 'spec_helper'
require 'app/presenters/paginated_presenter'

# A collection that behaves like a Kaminari relation
PaginatedSet = Struct.new(:current_page, :per_page, :total_count) do
  def default_per_page() per_page end

  def total_pages
    total_count.zero? ? 1 : (total_count.to_f / per_page).ceil
  end

  def first_page?() current_page == 1 end
  def last_page?() current_page == total_pages end

  def page(page)
    current_page = page
    self
  end

  def per(per)
    per_page = per
    self
  end
end

describe PaginatedPresenter do
  let(:presenter) { PaginatedPresenter.new(numbers, context: context) }
  let(:presented) { presenter.present(root: nil) }

  let(:context) do
    OpenStruct.new(
      request: OpenStruct.new(url: 'http://example.org/numbers'),
      params: {}
    )
  end

  context 'without enough items to give more than one page' do
    let(:numbers) { PaginatedSet.new(1, 25, 20) }

    it 'should not paginate' do
      expect(presenter.present).to eq({ 'count' => 20 })
    end
  end

  context 'with existing params' do
    let(:numbers) { PaginatedSet.new(1, 25, 50) }

    let(:context) do
      OpenStruct.new(
        request: OpenStruct.new(url: 'http://example.org/numbers'),
        params: { param: :value }
      )
    end

    it 'should keep existing params in pagination links' do
      links     = presenter.present['_links']
      next_link = links['next']
      last_link = links['last']

      expect(next_link).to eq('href' => 'http://example.org/numbers?page=2&param=value')
      expect(last_link).to eq('href' => 'http://example.org/numbers?page=2&param=value')
    end
  end

  context 'with enough items to paginate' do
    let(:links)   { presented['_links'] }
    let(:count)   { presented['count'] }

    context 'when on the first page' do
      let(:numbers) { PaginatedSet.new(1, 25, 100) }

      it 'should not give a "first" link' do
        expect(links['first']).to be_nil
      end

      it 'should not give a "prev" link' do
        expect(links['prev']).to be_nil
      end

      it 'should give a "last" link' do
        expect(links['last']).to eq('href' => 'http://example.org/numbers?page=4')
      end

      it 'should give a "next" link' do
        expect(links['next']).to eq('href' => 'http://example.org/numbers?page=2')
      end

      it 'should have a count' do
        expect(count).to eq(100)
      end
    end

    context 'when on the last page' do
      let(:numbers) { PaginatedSet.new(4, 25, 100) }

      it 'should not give a "last" link' do
        expect(links['last']).to be_nil
      end

      it 'should not give a "next" link' do
        expect(links['next']).to be_nil
      end

      it 'should give a "first" link' do
        expect(links['first']).to eq('href' => 'http://example.org/numbers?page=1')
      end

      it 'should give a "prev" link' do
        expect(links['prev']).to eq('href' => 'http://example.org/numbers?page=3')
      end

      it 'should have a count' do
        expect(count).to eq(100)
      end
    end

    context 'when somewhere comfortably in the middle' do
      let(:numbers) { PaginatedSet.new(3, 25, 101) }

      it 'should give all pagination links' do
        expect(links['first']).to eq('href' => 'http://example.org/numbers?page=1')
        expect(links['next']).to  eq('href' => 'http://example.org/numbers?page=4')
        expect(links['prev']).to  eq('href' => 'http://example.org/numbers?page=2')
        expect(links['last']).to  eq('href' => 'http://example.org/numbers?page=5')
      end

      it 'should have a count' do
        expect(count).to eq(101)
      end
    end
  end
end
