# Required base libraries
require 'artcom/capistrano-y60'
require 'railsless-deploy'

# Bootstrap Capistrano instance
configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  # --------------------------------------------
  # Task chains
  # --------------------------------------------
  after "deploy:setup", "y60:deploy:update_ldconfig"
  after "deploy:setup", "y60:deploy:update_environment"

  # --------------------------------------------
  # y60 specific tasks
  # --------------------------------------------
  namespace :y60 do
    namespace :deploy do

      desc "Add asl/lib & y60/lib to ldconfig"
      task :update_ldconfig, :roles => :app do
        run "echo '#{shared_path}/asl/lib' | #{sudo} tee /etc/ld.so.conf.d/asl.conf", :pty => true
        run "echo '#{shared_path}/y60/lib' | #{sudo} tee /etc/ld.so.conf.d/y60.conf", :pty => true
        run "#{sudo} /sbin/ldconfig", :pty => true
      end

      desc "Setup environment variable y60 'Y60_DIR"
      task :update_environment, :roles => :app do
        next if find_servers_for_task(current_task).empty?
        run "echo 'export Y60_DIR=#{shared_path}/y60/bin' | #{sudo} tee /etc/profile.d/y60.sh", :pty => true
      end

      desc "Copy Y60 engine including asl, watchdog"
      task :copy_binary, :roles => :app do
        top.upload("y60.tar.gz", "#{shared_path}", :via=> :scp)
        run "tar -C '#{shared_path}' -xzvf '#{shared_path}/y60.tar.gz'"
      end
    end
  end
end