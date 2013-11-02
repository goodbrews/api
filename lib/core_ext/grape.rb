module Grape
  class << self
    def env
      @env ||= ActiveSupport::StringInquirer.new(ENV['GRAPE_ENV'])
    end

    def root(*path)
      (@root ||= Pathname.new(ENV['GRAPE_ROOT']).join(*path)
    end
  end
end
