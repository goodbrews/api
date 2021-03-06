require 'app/models/style'
require 'app/presenters/paginated_presenter'

class StylePresenter < Jsonite
  properties :name, :category, :description, :min_abv, :max_abv, :min_ibu,
             :max_ibu, :min_original_gravity, :max_original_gravity,
             :min_final_gravity, :max_final_gravity

  property(:beers) { beers_count }

  link         { "/styles/#{self.to_param}" }
  link(:beers) { "/styles/#{self.to_param}/beers" }
end

class StylesPresenter < PaginatedPresenter
  property(:styles, with: StylePresenter) { to_a }
end
