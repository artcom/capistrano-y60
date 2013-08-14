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

  # --------------------------------------------
  # y60 specific tasks
  # --------------------------------------------
  namespace :y60 do

    desc "setup directory structure"
    task :setup_directory_structure, :roles => :app do
      run "mkdir -p #{y60_install_dir}/asl"
      run "mkdir -p #{y60_install_dir}/y60"
    end

    desc "Add asl/lib & y60/lib to ldconfig"
    task :update_ldconfig, :roles => :app do
      run "echo '#{y60_install_dir}/asl/lib' | #{sudo} tee /etc/ld.so.conf.d/asl.conf", :pty => true
      run "echo '#{y60_install_dir}/y60/lib' | #{sudo} tee /etc/ld.so.conf.d/y60.conf", :pty => true
      run "#{sudo} /sbin/ldconfig", :pty => true
    end

    desc "Setup environment variable y60 'Y60_DIR'"
    task :update_environment, :roles => :app do
      next if find_servers_for_task(current_task).empty?
      run "echo 'export Y60_DIR=#{y60_install_dir}/y60/bin' | #{sudo} tee /etc/profile.d/y60.sh", :pty => true
    end

    desc "Copy Y60 engine including asl, watchdog"
    task :copy_binary, :roles => :app do
      run "mkdir -p #{y60_install_dir}"
      top.upload("y60.tar.gz", "#{y60_install_dir}", :via=> :scp)
      run "tar -C '#{y60_install_dir}' -xzvf '#{y60_install_dir}/y60.tar.gz'"
    end
  end
end
