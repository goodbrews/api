require 'app/models/ingredient'
require 'miniskirt'

Factory.define :ingredient do |f|
  f.name { ['Centennial', 'Cascade', 'Amarillo'].sample }
  f.category 'Hops'
end
