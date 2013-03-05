# Capistrano-y60 gem
This is a gem with a collection of tasks for deploying y60 applications.

## Installing the gem
Best way to install the gem is to use bundler. Therefore create a
Gemfile and add the following requirements:

    source "https://rubygems.org"
    gem "capistrano", ">=2.12.0"
    gem "railsless-deploy", ">=1.0.2"
    gem "capistrano-ext", ">=1.2.1"
    gem "capistrano-y60", ">=0.0.15", :git => "git://github.com/artcom/capistrano-y60.git"

Call `bundle install` to install all required gems

## Usage
In your project repository or your deployment repository add the usual
capistrano hooks.
Then edit the deploy.rb and add the following lines:

    require 'artcom/capistrano-y60' 
    set :stages, %w(testing production)
    set :content_dirs, %w(/path/to/content ..)
    set :application, "kids-table"
    set :repository, "repo.git" unless defined?(repository)

No other settings are required as they are predefined in capistrano-y60.
You can overwrite the defaults by just setting the value

## Available tasks

A list with all available deployment tasks can be seen with the command
 `cap -T`

### Auto hooks
During `deploy:setup` and deploy there are several tasks for setting up
the target system environment already hooked 

#### deploy:setup hooks
Deploy:setup should only called once to setting up the target system environment.
After `deploy:setup` the following tasks will be automatically called:

    cap y60:update_environment                   # Setup environment variable 'Y60_DIR'
    cap y60:update_ldconfig                      # Add asl/lib and y60/lib to ldconfig 
    cap watchdog:update_environment              # Setup environment variable 'WATCHDOG_DIR'
    cap watchdog:update_ldconfig                 # Add asl/lib to ldconfig 
    cap y60:app:rsync_content                    # rsync content
    cap y60:app:setup_directory_structure        # setup directory structure
    cap y60:app:update_environment               # Set environment variable 'CONTENT_DIR'
    cap y60:linux:add_autostart                  # Add autostart behaviour
    cap y60:linux:add_kill_watchdog_desktop_link # Add kill watchdog Desktop link
    cap y60:linux:add_startapp_desktop_link      # Add start App Desktop link

#### deploy hooks
These tasks will be called everytime the project is deployed
After `deploy:finalize_update` the following tasks will be automatically called:

    cap y60:app:generate_app_settings_js         # generate app_settings.js
    cap y60:app:generate_watchdog_xml            # generate watchdog.xml
    cap y60:linux:generate_autostart_script      # generate application autostart script

### Other tasks
Other useful tasks are as follows:

    cap linux:deploy_ssh_key                     # deploy ssh key
    cap linux:reboot                             # Reboot the machine
    cap linux:shutdown                           # shutdown the machine
    cap y60:app:rsync_content                    # rsync content
    cap y60:app:setup_directory_structure        # setup directory structure
    cap y60:copy_binary                          # Copy Y60 engine including asl, watchdog
    cap y60:linux:kill_watchdog                  # kill watchdog
    cap y60:linux:restart_app                    # restart the app
    cap y60:linux:start_app                      # start watchdog & application

## Capistrano deployment structure

Capistrano deploy_to folder:

* releases - last x deployed releases for easy rollback
* current - symlink to the last successfully deployed release
* shared - folder for stuff that's not in the release and is shared over
  the different releases like content or settings 

## A deployed target system layout 

### Application folder
Applications are deployed into the home directory. 

* application folder includes:
    * in shared/config  - the watchdog.xml and an autostart script which uses this watchdog.xml
    * in shared/content - content like movies which are not in the git repository
    * in shared/y60 - y60 engine
    * in shared/asl - asl artcom standard library
    * in shared/watchdog - watchdog

### Autostart
* ~/bin/autostart - script that executes all scripts in ~/Autostart during system startup
* ~/Autostart - place for your autostart scripts that should start during system boot
* ~/.config/autostart/autostart.sh.desktop - gnome autostart folder where a desktop link is placed that executes the script ~/bin/autostart

### Environment
* export scripts for Y60_DIR, WATCHDOG_DIR, CONTENT_DIR are placed in /etc/profile.d/ and helps the application to find all dependencies
* to find asl and the y60 engine ldconfig config files are placed in /etc/ld.so.conf.d/
* desktop links are placed in ~/Desktop to start the application and kill it
 
## Deploying Y60, ASL, Watchdog

Because the target platform almost always differs from the development
platform, the deployment is based on building y60 engine elsewhere (e.q.
VM) and then deploy it with capistrano.
Therefore get yourself a y60.tar.gz with the engine and then deploy it
with `cap <stage> y60:copy_binary`.


- - -
*Copyright (c) [ART+COM AG](http://www.artcom.de/), Berlin Germany 2013 - Author: Gunnar Marten (gunnar.marten@artcom.de)*

