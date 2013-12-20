require 'app/models/ingredient'

class IngredientPresenter < Jsonite
  properties :name, :category
end
