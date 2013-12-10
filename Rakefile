ENV['GRAPE_ENV']  ||= ENV['RACK_ENV'] ||= 'development'
ENV['GRAPE_ROOT'] ||= Dir.pwd

# Active Record rake tasks
task :environment do
  # Set up environment
  app_root = Pathname.new(ENV['GRAPE_ROOT'])
  ActiveRecord::Tasks::DatabaseTasks.db_dir = app_root.join('db')

  # Establish a connection to the correct database
  database_spec = YAML.load_file('config/database.yml')[ENV['GRAPE_ENV']]
  ActiveRecord::Base.establish_connection(database_spec)

  # Set up logging
  log = app_root.join('log', "#{ENV['GRAPE_ENV']}.log")
  ActiveRecord::Base.logger = Logger.new(File.open(log, 'w+'))
end

load 'active_record/railties/databases.rake'
