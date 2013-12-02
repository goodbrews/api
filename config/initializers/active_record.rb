database_spec = YAML.load_file('config/database.yml')[Grape.env]
ActiveRecord::Base.establish_connection(database_spec)

ActiveRecord::Base.default_timezone = Goodbrews::Application.time_zone
