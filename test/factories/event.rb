require 'miniskirt'

Factory.define :event do |f|
  f.name        { "#{Faker::Name.last_name} Brewfest" }
  f.description { Faker::Lorem.paragraph }
  f.category    'Brewfest'

  f.year { Date.today.year }

  f.start_date { Date.yesterday }
  f.end_date { Date.tomorrow }
  f.hours '1pm - 7pm'
  f.price '$30'

  f.venue       { Faker::Company.name }
  f.street      { Faker::Address.street_address }
  f.street2     { Faker::Address.secondary_address }
  f.city        { Faker::Address.city }
  f.region      { Faker::AddressUS.state_abbr }
  f.postal_code { Faker::AddressUS.zip_code }
  f.country     'USA'

  f.latitude  { Faker::Geolocation.lat }
  f.longitude { Faker::Geolocation.lng }

  f.website { Faker::Internet.uri(:http) }
  f.phone   { Faker::PhoneNumber.phone_number }

  f.brewerydb_id { SecureRandom.hex(3).upcase }
  f.image_id     { SecureRandom.hex(3).upcase }
end
