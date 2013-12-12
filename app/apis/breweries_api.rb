require 'app/models/brewery'

class BreweriesAPI < Grape::API
  namespace :breweries do
    desc "Return a list of breweries."
    get do
      Brewery.all
    end
  end
end
