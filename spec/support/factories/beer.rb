require 'miniskirt'
require 'ffaker'

Factory.define :beer do |f|
  f.name { "#{Faker::Name.last_name} Ale" }
  f.style { Factory(:style) }
  f.breweries { [Factory(:brewery)] }

  f.description { Faker::Lorem.paragraph }
  f.availability 'Year-round'
  f.glassware 'Pint glass'
  f.organic { [true, false].sample }

  f.abv { |b| rand((b.style.min_abv)..(b.style.max_abv)).round(2) }
  f.ibu { |b| rand((b.style.min_ibu)..(b.style.max_ibu)).to_i }
  f.original_gravity { |b| rand((b.style.min_original_gravity)..(b.style.max_original_gravity)) }
  f.serving_temperature { rand(54.0..57.0).round(1) }

  f.brewerydb_id { SecureRandom.hex(3).upcase }
  f.image_id { SecureRandom.hex(3).upcase }
end
