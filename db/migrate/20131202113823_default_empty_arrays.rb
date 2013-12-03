class DefaultEmptyArrays < ActiveRecord::Migration
  def change
    change_column_default :breweries, :alternate_names, '{}'
  end
end
