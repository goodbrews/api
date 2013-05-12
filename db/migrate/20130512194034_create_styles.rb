class CreateStyles < ActiveRecord::Migration
  def change
    create_table :styles do |t|
      t.string  :name
      t.string  :category
      t.text    :description

      t.float   :min_abv
      t.float   :max_abv
      t.integer :min_ibu
      t.integer :max_ibu
      t.float   :min_original_gravity
      t.float   :max_original_gravity
      t.float   :min_final_gravity
      t.float   :max_final_gravity

      t.string  :slug

      t.index   :slug, unique: true
      t.index   :category

      t.timestamps
    end
  end
end
