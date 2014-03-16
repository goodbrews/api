require 'miniskirt'

Factory.define :auth_token do |f|
  f.user { Factory(:user) }
end
