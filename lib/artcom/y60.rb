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
  after "deploy:setup", "y60:setup_directory_structure"
  after "deploy:setup", "y60:update_ldconfig"
  after "deploy:setup", "y60:update_environment"
  after "deploy:setup", "y60:add_startapp_desktop_link"
  after "deploy:setup", "y60:generate_autostart_script"

  # --------------------------------------------
  # y60 specific tasks
  # --------------------------------------------
  namespace :y60 do

    # --------------------------------------------
    # setup target system environment
    # --------------------------------------------

    desc "setup directory structure"
    task :setup_directory_structure, :roles => :app do
      run "mkdir -p #{y60_install_dir}/y60"
    end

    desc "Add y60/lib to ldconfig"
    task :update_ldconfig, :roles => :app do
      run "echo '#{y60_install_dir}/y60/lib' | #{sudo} tee /etc/ld.so.conf.d/y60.conf", :pty => true
      run "#{sudo} /sbin/ldconfig", :pty => true
    end

    desc "Setup environment variable y60 'Y60_DIR'"
    task :update_environment, :roles => :app do
      next if find_servers_for_task(current_task).empty?
      run "echo 'export Y60_DIR=#{y60_install_dir}/y60/bin' | #{sudo} tee /etc/profile.d/y60.sh", :pty => true
    end

    # --------------------------------------------
    # autostart behaviour
    # --------------------------------------------

    desc "generate autostart script"
    task :generate_autostart_script, :roles => :app do
      myScript = <<-SCRIPT
  #!/bin/sh
  $WATCHDOG_DIR/watchdog #{shared_path}/config/watchdog.xml
      SCRIPT
      myLocation = "#{shared_path}/config/#{application}"
      put_sudo myScript, myLocation
      run "sudo chmod +x #{shared_path}/config/#{application}"
      puts "Generated autostart at #{myLocation}."
      run "ln -sf #{shared_path}/config/#{application} #{deploy_to}/../Autostart/#{application} "
      puts "symlinked to #{deploy_to}/../Autostart."
    end

    desc "Add start app desktop link"
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
      put_sudo myAutostart, myLocation
      run "chmod +x #{deploy_to}/../Desktop/#{application}.sh.desktop"
    end

    desc "Add kill watchdog and y60 desktop link"
    task :add_kill_watchdog_and_y60_desktop_link, :roles => :app do
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
      myLocation = "#{deploy_to}/../Desktop/kill_#{application}.sh.desktop"
      put_sudo myKillWatchdogScript, myLocation
      run "chmod +x #{deploy_to}/../Desktop/kill_#{application}.sh.desktop"
    end

    desc "start watchdog & application"
    task :start_app, :roles => :app do
      next if find_servers_for_task(current_task).empty?
      run "#{shared_path}/config/#{application}"
    end

    desc "restart the app"
    task :restart_app, :roles => :app do
      run "sudo killall y60"
    end

    # --------------------------------------------
    # deployment
    # --------------------------------------------

    desc "Copy Y60 engine"
    task :copy_package, :roles => :app do
      run "mkdir -p #{y60_install_dir}/y60"
      delete_artifact = false
      version = fetch(:y60_version, "1.0.9")
      target_platform = fetch(:y60_target_platform, "Linux-x86_64")
      package = fetch(:y60_package, "Y60-#{version}-#{target_platform}.tar.gz")
      if not File.file?(package)
        run_locally "scp artifacts@artifacts:pro60/releases/#{package} #{package}"
        delete_artifact = true
      end
      top.upload(package, "#{y60_install_dir}", :via=> :scp)
      if delete_artifact
        run_locally "rm -rf #{package}"
      end
      run "tar -C '#{y60_install_dir}/y60' --exclude include --strip-components 1 -xzvf '#{y60_install_dir}/#{package}'"
      run "rm #{y60_install_dir}/#{package}"
      sudo "chown -R #{runner}:#{runner} #{y60_install_dir}"      
    end
  end
end
