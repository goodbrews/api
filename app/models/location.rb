require 'app/models/brewery'

class Location < ActiveRecord::Base
  belongs_to :brewery
  validates  :brewery, presence: true
end
