module Grape
  class << self
    def env
      @env ||= ActiveSupport::StringInquirer.new(ENV['GRAPE_ENV'])
    end

    def root(*paths)
      (@root ||= Pathname.new(ENV['GRAPE_ROOT'])).join(*paths)
    end
  end
end
