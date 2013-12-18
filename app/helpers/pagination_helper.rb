module PaginationHelper
  def paginate(collection)
    page       = params.fetch(:page, 1)
    per_page   = params.fetch(:per_page, collection.default_per_page)

    total      = collection.count
    collection = collection.page(page).per(per_page)
    links      = render_links(collection, page, per_page)

    headers['Total'] = total.to_s if total
    headers['Link']  = links unless links.empty?

    collection
  end

  private

    def render_links(collection, page, per_page)
      links = (headers['Link'] || '').split(', ').map(&:strip)
      url   = URI(request.url)
      pages = {}

      unless collection.first_page?
        pages[:first] = 1
        pages[:prev]  = collection.current_page - 1
      end

      unless collection.last_page?
        pages[:last] = collection.total_pages
        pages[:next] = collection.current_page + 1
      end

      pages.each do |k, v|
        url   += "?#{params.merge(page: v).to_query}"
        links << %(<#{url}>; rel="#{k}")
      end

      links.join(', ')
    end
end
