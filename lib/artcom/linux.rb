# Required base libraries
require 'artcom/capistrano-y60'
require 'railsless-deploy'

# Bootstrap Capistrano instance
configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  # --------------------------------------------
  # Task hooks
  # --------------------------------------------
  after "deploy:setup", "linux:add_autostart_behaviour"

  # --------------------------------------------
  # common linux tasks
  # --------------------------------------------
  namespace :linux do
    desc "Reboot the machine"
    task :reboot, :roles => :app do
      sudo "/sbin/shutdown -r now", :pty => true
    end

    desc "shutdown the machine"
    task :shutdown, :roles => :app do
      sudo "/sbin/shutdown now", :pty => true
    end

    desc "deploy ssh key"
    task :deploy_ssh_key do
      servers = find_servers_for_task(current_task)
      servers.each do |server|
        system("ssh-copy-id '#{user}@#{server}'")
      end
    end

  # --------------------------------------------
  # autostart behaviour
  # --------------------------------------------
    desc "setup autostart behaviour"
    task :add_autostart_behaviour, :roles => :app do
      run "mkdir -p #{deploy_to}/../Autostart"
      run "mkdir -p #{deploy_to}/../bin"
      run "mkdir -p #{deploy_to}/../.config/autostart"
      myScript = <<-SCRIPT
  #!/bin/sh
  for i in `ls ~/Autostart/*`; do
    "$i" &
  done
      SCRIPT
      myLocation = "#{deploy_to}/../bin/autostart.sh"
      put myScript, myLocation
      run "chmod +x #{deploy_to}/../bin/autostart.sh"
      puts "Generated autostart at #{myLocation}."
      myAutostart = <<-SCRIPT
  [Desktop Entry]
  Type=Application
  Exec=#{deploy_to}/../bin/autostart.sh
  Hidden=false
  NoDisplay=false
  X-GNOME-Autostart-enabled=true
  Name[en_US]=Autostart
  Name=Autostart
  Comment[en_US]=starts all scripts in ~/Autostart
  Comment=starts all scripts in ~/Autostart
      SCRIPT
      myLocation = "#{deploy_to}/../.config/autostart/autostart.sh.desktop"
      put myAutostart, myLocation
    end
  end
end
