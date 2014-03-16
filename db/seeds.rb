require File.expand_path("../../config/application", __FILE__)
Dir[Crepe.root.join('spec/support/**/*.rb')].each { |f| require f }

##
# Styles
##
styles = %w[
  Strong Ale
  Scotch Ale
  Golden or Blonde Ale
  Fresh Hop Ale
  American-Style Strong Pale Ale
  Imperial or Double India Pale Ale
  American-Style Amber/Red Ale
  Imperial or Double Red Ale
  American-Style Brown Ale
  American-Style Sour Ale
  American-Style Black Ale
  American-Style Imperial Stout
  Belgian-Style Quadrupel
  Belgian-Style Blonde Ale
  Belgian-Style Pale Ale
  Belgian-Style Pale Strong Ale
  Belgian-Style White (or Wit) / Belgian-Style Wheat
  Old Ale
  British-Style Barley Wine Ale
  American-Style Pale Ale
  American-Style India Pale Ale
  American-Style Barley Wine Ale
  American-Style Stout
  Belgian-Style Dubbel
  Belgian-Style Tripel
  Belgian-Style Dark Strong Ale
  French & Belgian-Style Saison
  Baltic-Style Porter
]

styles.map! do |name|
  style = Style.find_by(name: name)
  style ||= Factory(:style, name: name)
  style
end

##
# Breweries
##

brewery = Factory(:brewery)

##
# Locations
##

location = Factory(:location, brewery: brewery)

##
# Ingredients
##

ingredients = %w[Amarillo Cascade Chinook Citra Crystal Nugget Simcoe Spalt]

ingredients.map! do |hop|
  ingredient = Ingredient.find_or_initialize_by(name: hop)
  ingredient.category = 'Hops'
  ingredient.save!
  ingredient
end

##
# Beers
##

beers = []

111.times do
  beers << Factory(:beer, {
    style: styles.sample,
    breweries: [brewery],
    ingredients: ingredients.sample(3)
  })
end

##
# Events
##

event = Factory(:event, {
  beers: beers.sample(25),
  breweries: [brewery]
})

##
# Guilds
##

guild = Factory(:guild, breweries: [brewery])

##
# Social Media Accounts
##

social_accounts = [Factory(:social_media_account, socialable: brewery)]

beers.sample(25).each do |beer|
  social_accounts << Factory(:social_media_account, socialable: beer)
end

##
# User
##

puts 'Creating a user...'
print 'Username: '
username = STDIN.gets.chomp

print 'Email: '
email = STDIN.gets.chomp

print 'Password: '
password = STDIN.noecho(&:gets).chomp

Factory(:user, {
  username: username,
  email: email,
  password: password,
  password_confirmation: password
})
