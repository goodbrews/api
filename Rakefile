require File.expand_path('../config/application', __FILE__)

# Active Record rake tasks
task :environment do
  # Set up environment
  app_root = Pathname.new(ENV['CREPE_ROOT'])
  ActiveRecord::Tasks::DatabaseTasks.db_dir = app_root.join('db')

  # Establish a connection to the correct database
  database_spec = YAML.load_file('config/database.yml')[ENV['CREPE_ENV']]
  ActiveRecord::Base.establish_connection(database_spec)

  # Set up logging
  log = app_root.join('log', "#{ENV['CREPE_ENV']}.log")
  ActiveRecord::Base.logger = Logger.new(File.open(log, 'w+'))
end

load 'active_record/railties/databases.rake'
