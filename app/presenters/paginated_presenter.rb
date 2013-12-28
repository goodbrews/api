class PaginatedPresenter < Jsonite
  def initialize(resource, defaults = {})
    super

    context  = defaults[:context]
    page     = context.params.fetch(:page, 1)
    per_page = context.params.fetch(:per_page, @resource.default_per_page)

    @resource = @resource.page(page).per(per_page)
  end

  property(:count) { total_count }

  link :first do |context|
    throw :ignore if first_page?

    url   = URI(context.request.url)
    query = context.params.merge(page: 1).to_query

    "#{url}?#{query}"
  end

  link :prev do |context|
    throw :ignore if first_page?

    url   = URI(context.request.url)
    query = context.params.merge(page: current_page - 1).to_query

    "#{url}?#{query}"
  end

  link :next do |context|
    throw :ignore if last_page?

    url   = URI(context.request.url)
    query = context.params.merge(page: current_page + 1).to_query

    "#{url}?#{query}"
  end

  link :last do |context|
    throw :ignore if last_page?

    url   = URI(context.request.url)
    query = context.params.merge(page: total_pages).to_query

    "#{url}?#{query}"
  end
end

