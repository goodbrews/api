require 'miniskirt'
require 'ffaker'

Factory.define :guild do |f|
  f.name         { "#{Faker::AddressUS.state} Brewer's Guild" }
  f.description  { Faker::Lorem.paragraph }
  f.website      { Faker::Internet.uri(:http) }
  f.established  { rand(1943..Date.today.year) }

  f.brewerydb_id { SecureRandom.hex(3).upcase }
  f.image_id     { SecureRandom.hex(3).upcase }
end
