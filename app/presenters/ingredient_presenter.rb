require 'app/models/ingredient'
require 'app/presenters/paginated_presenter'

class IngredientPresenter < Jsonite
  properties :name, :category

  property(:beers) { beers_count }
end

class IngredientsPresenter < PaginatedPresenter
  property(:ingredients, with: IngredientPresenter) { to_a }
end
