module Grape
  class << self
    def env
      @env ||= ActiveSupport::StringInquirer.new(ENV['GRAPE_ENV'])
    end

    def root
      @root ||= Pathname.new(ENV['GRAPE_ROOT'])
    end
  end
end
