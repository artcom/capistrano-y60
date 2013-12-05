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
  require 'artcom/y60component'
  require 'artcom/watchdog'
  require 'artcom/app'

  # Multistage
  _cset :stages, %w()
  _cset :default_stage, ""

  # User details
  _cset :user,          'artcom'
  _cset(:group)         { user }

  # Application details
  _cset(:runner)        { user }
  _cset :y60_components, %w()
  #_cset(:y60_install_dir)  { "#{shared_path}" }
  set :use_sudo,      false

  # SCM settings
  set :scm,           'git'
  set :git_shallow_clone, 1
  set :branch,        'master'
  set :keep_releases, 5
  set :deploy_via,    :copy
  set :copy_strategy, :export

  # Git settings for capistrano
  default_run_options[:pty]     = true # needed for git password prompts
  ssh_options[:forward_agent]   = true # use the keys for the person running the cap command to check out the app
end
