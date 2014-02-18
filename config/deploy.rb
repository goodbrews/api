# Configuration only for Capistrano 3.1
lock '3.1.0'

set :application, 'api'
set :repo_url, 'https://github.com/goodbrews/api.git'

# Default branch is :master
set :branch, :deployment

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/goodbrews/api'

# Set a Ruby for chruby to use
set :chruby_ruby, 'ruby-2.1.0'

# Default value for sidekiq_pidfile is tmp/sidekiq.pid
set :sidekiq_pid, 'tmp/pids/sidekiq.pid'

# Default value for linked_files is []
set :linked_files, %w[.env]

# Default value for linked_dirs is []
set :linked_dirs, %w[bin log tmp/pids tmp/sockets vendor/bundle]

# Default value for default_env is {}
# set :default_env, {}

# Default value for keep_releases is 5
# set :keep_releases, 5
