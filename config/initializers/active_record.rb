database_spec = YAML.load_file('config/database.yml')[Crepe.env]
ActiveRecord::Base.establish_connection(database_spec)
ActiveRecord::Base.default_timezone = :utc
