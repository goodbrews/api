require 'app/models/social_media_account'
require 'miniskirt'

Factory.define :social_media_account do |f|
  f.website 'BeerAdvocate'
  f.handle  10099

  f.socialable { Factory(:brewery) }
end
