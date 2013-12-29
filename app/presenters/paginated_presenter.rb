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

    "#{context.url}?#{context.query_params.merge(page: 1).to_query}"
  end

  link :prev do |context|
    throw :ignore if first_page?

    "#{context.url}?#{context.query_params.merge(page: current_page - 1).to_query}"
  end

  link :next do |context|
    throw :ignore if last_page?

    "#{context.url}?#{context.query_params.merge(page: current_page + 1).to_query}"
  end

  link :last do |context|
    throw :ignore if last_page?

    "#{context.url}?#{context.query_params.merge(page: total_pages).to_query}"
  end
end

