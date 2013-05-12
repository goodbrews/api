require 'miniskirt'

Factory.define :brewery do |f|
  f.name { "#{Faker::Name.last_name} Brewing" }
  f.alternate_names { |b| [b.name.gsub('Brewing', 'Brewery')] }
  f.description { Faker::Lorem.paragraph }
  f.website { Faker::Internet.uri(:http) }
  f.organic { [true, false].sample }
  f.established { rand(1040..Date.today.year) }
end
