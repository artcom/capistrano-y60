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
  after "deploy:setup", "y60:linux:add_autostart"
  after "deploy:setup", "y60:linux:add_kill_watchdog_desktop_link"
  after "deploy:setup", "y60:linux:add_startapp_desktop_link"

  after "deploy:finalize_update", "y60:linux:generate_autostart_script"
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
  end

  # --------------------------------------------
  # y60 specific linux tasks
  # --------------------------------------------
  namespace :y60 do
    namespace :linux do
      desc "generate application autostart script"
      task :generate_autostart_script, :roles => :app do
        myScript = <<-SCRIPT
    #!/bin/sh
    $WATCHDOG_DIR/watchdog #{shared_path}/config/watchdog.xml
        SCRIPT
        myLocation = "#{shared_path}/config/#{application}"
        put myScript, myLocation
        run "chmod +x #{shared_path}/config/#{application}"
        puts "Generated autostart at #{myLocation}."
        run "ln -sf #{shared_path}/config/#{application} #{deploy_to}/../Autostart/#{application} "
        puts "symlinked to #{deploy_to}/../Autostart."
      end

      desc "Add autostart behaviour"
      task :add_autostart, :roles => :app do
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

    desc "Add start App Desktop link"
      task :add_startapp_desktop_link, :roles => :app do
        myAutostart = <<-SCRIPT
    [Desktop Entry]
    Type=Application
    Exec=#{shared_path}/config/#{application}
    Hidden=false
    NoDisplay=false
    X-GNOME-Autostart-enabled=true
    Name[en_US]=#{application}
    Name=#{application}
    Comment[en_US]=starts #{application}
    Comment=starts #{application}
        SCRIPT
        myLocation = "#{deploy_to}/../Desktop/#{application}.sh.desktop"
        put myAutostart, myLocation
        run "chmod +x #{deploy_to}/../Desktop/#{application}.sh.desktop"
      end

      desc "Add kill watchdog Desktop link"
      task :add_kill_watchdog_desktop_link, :roles => :app do
        myKillWatchdogScript = <<-SCRIPT
    [Desktop Entry]
    Type=Application
    Exec=killall watchdog && killall y60
    Hidden=false
    NoDisplay=false
    X-GNOME-Autostart-enabled=true
    Name[en_US]=Kill watchdog
    Name=Kill watchdog
    Comment[en_US]=kills the watchdog & y60
    Comment=kills the watchdog & y60
        SCRIPT
        myLocation = "#{deploy_to}/../Desktop/kill_watchdog.sh.desktop"
        put myKillWatchdogScript, myLocation
        run "chmod +x #{deploy_to}/../Desktop/kill_watchdog.sh.desktop"
      end

      desc "restart the app"
      task :restart_app, :roles => :app do
        run "killall y60"
      end

      desc "kill watchdog"
      task :kill_watchdog, :roles => :app do
        run "killall watchdog"
      end

      desc "start watchdog & application"
      task :start_app, :roles => :app do
        next if find_servers_for_task(current_task).empty?
        run "#{shared_path}/config/#{application}"
      end
    end
  end
end
