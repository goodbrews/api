# Convenience Rails-style ENV variables.
ENV['GRAPE_ENV']  ||= ENV['RACK_ENV'] ||= 'development'
ENV['GRAPE_ROOT'] ||= Dir.pwd
$LOAD_PATH.unshift ENV['GRAPE_ROOT']
$LOAD_PATH.unshift File.join(ENV['GRAPE_ROOT'], 'lib')

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
