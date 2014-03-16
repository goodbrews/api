require 'app/models/user'
require 'miniskirt'
require 'ffaker'

Factory.define :user do |f|
  f.email 'user.%d@goodbre.ws'
  f.username 'user_%d'
  f.password f.password_confirmation('supersecret')

  f.name { Faker::Name.name }
  f.city { Faker::Address.city }
  f.region { Faker::AddressUS.state_abbr }
  f.country 'USA'
  f.latitude { Faker::Geolocation.lat }
  f.longitude { Faker::Geolocation.lng }
end
