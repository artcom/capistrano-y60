# Capistrano2 differentiator
load 'deploy' if respond_to?(:namespace)

# Required gems/libraries
require 'rubygems'
require 'fileutils'
require 'artcom/common'
begin
  require 'capistrano/ext/multistage' # gem install capistrano-ext
rescue LoadError
  puts "'capistrano-ext' gem is required on the local machine"
end

begin
  require 'railsless-deploy'
rescue LoadError
  puts "'railsless-deploy' gem is required on the local machine"
end

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do

  # Load library
  require 'artcom/linux'
  require 'artcom/y60'
  require 'artcom/watchdog'
  require 'artcom/app'

  # Multistage
  set :stages, %w(testing production)
  set :default_stage, "testing"

  # User details
  _cset :user,          'artcom'
  _cset(:group)         { user }

  # Application details
  _cset(:application)      { abort "Please specify the short name of your application, set :application, 'foo'" }
  _cset(:runner)        { user }
  _cset :use_sudo,      false

  # SCM settings
  _cset :scm,           'git'
  _cset :git_shallow_clone, 1
  _cset :branch,        'master'
  _cset :keep_releases, 5
  _cset :deploy_via,    'copy'
  _cset :copy_strategy, 'export'

  # Git settings for capistrano
  default_run_options[:pty]     = true # needed for git password prompts
  ssh_options[:forward_agent]   = true # use the keys for the person running the cap command to check out the app
end
