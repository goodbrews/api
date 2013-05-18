require 'miniskirt'

Factory.define :location do |f|
  f.brewery { Factory(:brewery) }

  f.name     { |l| l.brewery.name }
  f.category 'Brewpub'

  f.primary     true
  f.in_planning false
  f.public      true
  f.closed      false

  f.street      { Faker::Address.street_address }
  f.street2     { Faker::Address.secondary_address }
  f.city        { Faker::Address.city }
  f.region      { Faker::AddressUS.state_abbr }
  f.postal_code { Faker::AddressUS.zip_code }
  f.country     'USA'

  f.latitude  { Faker::Geolocation.lat }
  f.longitude { Faker::Geolocation.lng }

  f.hours   <<-HOURS.strip_heredoc
              Monday - Thursday 11:30 am - 11:00 pm
              Friday - Saturday 11:30 am - 12:00 am
              Sunday 12:00 pm - 9:00 pm
            HOURS

  f.website      { |l| l.brewery.website }
  f.phone        { Faker::PhoneNumber.phone_number }
  f.brewerydb_id { SecureRandom.hex(3).upcase }
end
