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
  after "deploy:setup", "watchdog:setup_directory_structure"
  after "deploy:setup", "watchdog:update_environment"
  after "deploy:setup", "watchdog:update_ldconfig"

  # --------------------------------------------
  # watchdog specific tasks
  # --------------------------------------------
  namespace :watchdog do

    desc "setup directory structure"
    task :setup_directory_structure, :roles => :app do
      run "mkdir -p #{y60_install_dir}/asl"
      run "mkdir -p #{y60_install_dir}/watchdog"
    end

    desc "Add asl/lib to ldconfig"
    task :update_ldconfig, :roles => :app do
      run "echo '#{y60_install_dir}/asl/lib' | #{sudo} tee /etc/ld.so.conf.d/asl.conf", :pty => true
      run "#{sudo} /sbin/ldconfig", :pty => true
    end
    desc "Setup environment variable watchdog 'WATCHDOG_DIR'"
    task :update_environment, :roles => :app do
      next if find_servers_for_task(current_task).empty?
      run "echo 'export WATCHDOG_DIR=#{y60_install_dir}/watchdog/bin' | #{sudo} tee /etc/profile.d/watchdog.sh", :pty => true
    end
    desc "Copy watchdog including asl"
    task :copy_binary, :roles => :app do
      top.upload("watchdog.tar.gz", "#{y60_install_dir}", :via=> :scp)
      run "tar -C '#{y60_install_dir}' -xzvf '#{y60_install_dir}/watchdog.tar.gz'"
    end
  end
end
