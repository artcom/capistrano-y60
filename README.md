This is a collection of tasks for deploying y60 applications.
You need to load them in your Capfile with something like:

Dir['path/to/y60_capistrano_recipes/recipes/*.rb'].each { |plugin| load(plugin) }

# Available tasks

With the command
 cap -T

you see all available deployment tasks

## Deploying Y60, ASL, Watchdog

It is often the case that your deployment system and your target system differ. In that case build the libs and binaries in a VM or so get yourself a y60.tar.gz with all included and use the task

 cap <stage> y60_deploy:copy_engine

 which deploys the y60, ASL, watchdog to the target system

Only called once to initially setup the target system
 cap <stage> deploy:setup
 Includes the following tasks: 
"linux:update_common_environment" - exports the COMMON_DIR env variable by creating a export script and copy it to the appropriate folder
"linux:add_autostart" - creates and adds all necessary autostart scripts
"linux:add_kill_watchdog_desktop_link" - creates and copies desktop link to kill the watchdog and the app
deploy hooks

Called every time you want to deploy common. Clones the current HEAD from the remote git repo and deploys it to the target system
 cap <stage> deploy
Deploying the application

A three stage deployment. deploy:setup is only called once to initially setup the target system. deploy is called every time you want to deploy the application and content_deploy:rsync_content is called every time you want to deploy the content.
deploy:setup hooks
 cap <stage> deploy:setup
 Includes the following tasks: 
"asl_deploy:update_ldconfig" - creates a ldconfig config file and copies it to the appropriate folder and then executes ldconfig
"y60_deploy:update_ldconfig" - creates a ldconfig config file and copies it to the appropriate folder and then executes ldconfig
"y60_deploy:update_environment" - exports the Y60_DIR env variable by creating a export script and copy it to the appropriate folder
"watchdog_deploy:update_environment" - exports the WATCHDOG_DIR env variable by creating a export script and copy it to the appropriate folder
"content_deploy:update_environment" - exports the CONTENT_DIR env variable by creating a export script and copy it to the appropriate folder
"linux:add_startapp_desktop_link" - creates and copies desktop link to start the app
deploy hooks

Clones the current HEAD from the remote git repo and deploys it to the target system.
 cap <stage> deploy
 Always creates and deploys the new watchdog.xml and the autostart script with the following tasks: 
"app_deploy:generate_watchdog_xml" 
"linux:generate_autostart_script"
Deploying the content

On your native development machine use:
./getdata.sh

Then use the following capistrano task to deploy the content to the target system:
 cap <stage> content_deploy:rsync_content
 
- - -
*Copyright (c) [ART+COM AG](http://www.artcom.de/), Berlin Germany 2012 - Author: Gunnar Marten (gunnar.marten@artcom.de)*

