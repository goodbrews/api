require 'miniskirt'

Factory.define :beer do |f|
  f.name { "#{Faker::Name.last_name} Ale" }
  f.style { Factory(:style) }

  f.description { Faker::Lorem.paragraph }
  f.availability 'Year-round'
  f.glassware 'Pint glass'
  f.organic { [true, false].sample }

  f.abv { |b| rand((b.style.min_abv)..(b.style.max_abv)) }
  f.ibu { |b| rand((b.style.min_ibu)..(b.style.max_ibu)) }
  f.original_gravity { |b| rand((b.style.min_original_gravity)..(b.style.max_original_gravity)) }
  f.serving_temperature { rand(54..57) }

  f.brewerydb_id { SecureRandom.hex(3).upcase }
  f.image_id { SecureRandom.hex(3).upcase }
end
