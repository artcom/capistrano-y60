
configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)
  
configuration.load do
  
#
# Configuration
#

require 'rubygems'
require 'fileutils'

# Multistage
 _cset(:default_stage) { 'testing' }
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

# load library
require 'artcom/common'
require 'artcom/app_deploy'
require 'artcom/asl_deploy'
require 'artcom/content_deploy'
require 'artcom/linux'
require 'artcom/watchdog_deploy'
require 'artcom/y60_deploy'

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

after 'deploy:setup' do
  run "mkdir -p #{shared_path}/asl"
  run "mkdir -p #{shared_path}/y60"
  run "mkdir -p #{shared_path}/watchdog"
  run "mkdir -p #{shared_path}/config"
  run "mkdir -p #{shared_path}/content"
end

after "deploy:setup", "asl_deploy:update_ldconfig"
after "deploy:setup", "y60_deploy:update_ldconfig", "y60_deploy:update_environment"
after "deploy:setup", "watchdog_deploy:update_environment"
after "deploy:setup", "common_deploy:update_environment", "linux:add_autostart", "linux:add_kill_watchdog_desktop_link"
after "deploy:setup", "linux:add_startapp_desktop_link"

after "deploy:finalize_update", "app_deploy:generate_watchdog_xml"
after "deploy:finalize_update", "app_deploy:generate_app_settings_js"
after "deploy:finalize_update", "linux:generate_autostart_script"


end
