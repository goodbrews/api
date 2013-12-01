module Sluggable
  extend ActiveSupport::Concern

  included do
    before_create :set_slug
    validates :slug, uniqueness: { case_sensitive: false }
  end

  def to_param
    slug
  end

  private

    def set_slug
      number = 1
      begin
        self.slug = self.name.parameterize
        self.slug += "-#{number}" if number > 1
        number += 1
      end while self.class.where(slug: self.slug).exists?
    end
end
