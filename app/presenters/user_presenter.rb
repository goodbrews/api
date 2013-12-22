require 'app/models/user'
require 'digest/md5'

class UserPresenter < Jsonite
  properties :username, :name, :city, :region, :country

  property(:email) do |context|
    throw :ignore unless self == context.current_user
    email
  end

  property(:likes)    { liked_beers_count }
  property(:dislikes) { disliked_beers_count }
  property(:cellar)   { bookmarked_beers_count }

  property :hidden do |context|
    throw :ignore unless self == context.current_user
    hidden_beers_count
  end

  link            { "/users/#{self.to_param}" }
  link(:likes)    { "/users/#{self.to_param}/likes" }
  link(:dislikes) { "/users/#{self.to_param}/dislikes" }
  link(:cellar)   { "/users/#{self.to_param}/cellar" }
  link(:similar)  { "/users/#{self.to_param}/similar" }

  link(:hidden) do |context|
    throw :ignore unless self == context.current_user
    "/users/#{self.to_param}/hidden"
  end

  link :gravatar, templated: true, size: '1..2048' do |context|
    hash = Digest::MD5.hexdigest(email.downcase)
    "https://secure.gravatar.com/avatar/#{hash}.jpg?s={size}"
  end
end
