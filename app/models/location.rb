require 'app/models/brewery'

class Location < ActiveRecord::Base
  belongs_to :brewery, counter_cache: true
  validates  :brewery, presence: true
end
