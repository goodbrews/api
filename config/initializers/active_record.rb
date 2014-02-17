database = YAML.load(ERB.new(File.read('config/database.yml')).result)[Crepe.env]
ActiveRecord::Base.establish_connection(database)
ActiveRecord::Base.default_timezone = :utc
