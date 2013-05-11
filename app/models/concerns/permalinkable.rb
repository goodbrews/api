module Permalinkable
  extend ActiveSupport::Concern

  included do
    before_create :generate_permalink
    validates_uniqueness_of :permalink, case_sensitive: false

    scope :from_param, -> param { find_by(permalink: param) }
  end

  def to_param
    self.permalink
  end

  private
    def generate_permalink
      number = 1
      begin
        self.permalink = self.name.parameterize
        self.permalink += "-#{number}" if number > 1
        number += 1
      end while self.class.where(permalink: self.permalink).exists?
    end
end
