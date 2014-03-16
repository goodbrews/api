require 'app/models/style'
require 'miniskirt'
require 'ffaker'

Factory.define :style do |f|
  f.name        'American-Style India Pale Ale'
  f.category    'North American Origin Ales'
  f.description { Faker::Lorem.paragraph }

  f.min_abv 6.3
  f.max_abv 7.5
  f.min_ibu 50
  f.max_ibu 70
  f.min_original_gravity 1.06
  f.max_original_gravity 1.09
  f.min_final_gravity 1.012
  f.max_final_gravity 1.018
end
