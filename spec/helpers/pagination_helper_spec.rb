require 'spec_helper'
require 'app/helpers/pagination_helper'

PaginatedSet = Struct.new(:current_page, :per_page, :total_count) do
  def default_per_page() per_page end
  def count() total_count end

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

describe PaginationHelper do
  let(:app) do
    Class.new(Crepe::API) do
      helper PaginationHelper

      get :numbers do
        page = params.fetch(:page, 1).to_i
        per_page = params.fetch(:per_page, 25)
        total = params.fetch(:count).to_i

        if params[:with_headers]
          url = request.url.sub(/\?.*/, '')
          query = params.except(:with_headers)
          headers['Link'] = %(<#{url}?#{query.to_param}>; rel="without")
        end

        collection = PaginatedSet.new(page, per_page, total)

        paginate collection
      end
    end
  end

  let(:links) { last_response.headers['Link'].split(', ') }

  context 'without enough items to give more than one page' do
    it 'should not paginate' do
      get :numbers, count: 20
      expect(last_response.headers.keys).not_to include('Link')
    end
  end

  context 'with existing Link headers' do
    before { get :numbers, count: 30, with_headers: true }

    it 'should keep existing Links' do
      expect(links).to include('<http://example.org/numbers?count=30>; rel="without"')
    end

    it 'should contain pagination Links' do
      expect(links).to include('<http://example.org/numbers?count=30&page=2&with_headers=true>; rel="next"')
      expect(links).to include('<http://example.org/numbers?count=30&page=2&with_headers=true>; rel="last"')
    end
  end

  context 'with enough items to paginate' do
    context 'when on the first page' do
      before { get :numbers, count: 100 }

      it 'should not give a link with rel "first"' do
        expect(links).not_to include('rel="first"')
      end

      it 'should not give a link with rel "prev"' do
        expect(links).not_to include('rel="prev"')
      end

      it 'should give a link with rel "last"' do
        expect(links).to include('<http://example.org/numbers?count=100&page=4>; rel="last"')
      end

      it 'should give a link with rel "next"' do
        expect(links).to include('<http://example.org/numbers?count=100&page=2>; rel="next"')
      end

      it 'should give a Total header with the number of total items' do
        expect(last_response.headers['Total']).to eq('100')
      end
    end

    context 'when on the last page' do
      before { get :numbers, count: 100, page: 4 }

      it 'should not give a link with rel "last"' do
        expect(links).not_to include('rel="last"')
      end

      it 'should not give a link with rel "next"' do
        expect(links).not_to include('rel="next"')
      end

      it 'should give a link with rel "first"' do
        expect(links).to include('<http://example.org/numbers?count=100&page=1>; rel="first"')
      end

      it 'should give a link with rel "prev"' do
        expect(links).to include('<http://example.org/numbers?count=100&page=3>; rel="prev"')
      end

      it 'should give a Total header with the number of total items' do
        expect(last_response.headers['Total']).to eq('100')
      end
    end

    context 'when somewhere comfortably in the middle' do
      before { get :numbers, count: 100, page: 2 }

      it 'should give all pagination links' do
        expect(links).to include('<http://example.org/numbers?count=100&page=1>; rel="first"')
        expect(links).to include('<http://example.org/numbers?count=100&page=4>; rel="last"')
        expect(links).to include('<http://example.org/numbers?count=100&page=3>; rel="next"')
        expect(links).to include('<http://example.org/numbers?count=100&page=1>; rel="prev"')
      end

      it 'should give a Total header with the number of total items' do
        expect(last_response.headers['Total']).to eq('100')
      end
    end
  end
end
