# Convenience Rails-style ENV variables.
ENV['GRAPE_ENV']  ||= ENV['RACK_ENV'] ||= 'development'
ENV['GRAPE_ROOT'] ||= Dir.pwd

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
