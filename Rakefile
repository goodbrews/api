require File.expand_path('../config/application', __FILE__)

# Active Record rake tasks
task :environment do
  # Set up environment
  ActiveRecord::Tasks::DatabaseTasks.db_dir = Crepe.root.join('db')

  # Establish a connection to the correct database
  database = YAML.load(ERB.new(File.read('config/database.yml')).result)[Crepe.env]
  ActiveRecord::Base.establish_connection(database)

  # Set up logging
  log = Crepe.root.join('log', "#{Crepe.env}.log")
  ActiveRecord::Base.logger = Logger.new(File.open(log, 'w+'))
end

load 'active_record/railties/databases.rake'
