require 'miniskirt'

Factory.define :user do |f|
  f.email { Faker::Internet.email }
  f.username { Faker::Internet.user_name }
  f.password f.password_confirmation 'supersecret'

  f.name { Faker::Name.name }
  f.city { Faker::Address.city }
  f.region { Faker::Address.us_state }
  f.country 'USA'
  f.latitude { Faker::Geolocation.lat }
  f.longitude { Faker::Geolocation.lng }
end
