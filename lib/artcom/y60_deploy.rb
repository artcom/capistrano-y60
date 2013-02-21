namespace :y60_deploy do

  desc "Add y60/lib to ldconfig"
  task :update_ldconfig, :roles => :app do
    run "echo '#{shared_path}/y60/lib' | #{sudo} tee /etc/ld.so.conf.d/y60.conf", :pty => true
    run "#{sudo} /sbin/ldconfig", :pty => true
  end

  desc "Setup environment variable y60 'Y60_DIR"
  task :update_environment, :roles => :app do
    next if find_servers_for_task(current_task).empty?
    run "echo 'export Y60_DIR=#{shared_path}/y60/bin' | #{sudo} tee /etc/profile.d/y60.sh", :pty => true
  end

  desc "Copy Y60 engine including asl, watchdog"
  task :copy_engine, :roles => :app do
    top.upload("y60.tar.gz", "#{shared_path}", :via=> :scp)    
    run "tar -C '#{shared_path}' -xzvf '#{shared_path}/y60.tar.gz'"
  end

  desc "push Y60 engine to deploy server"
  task :push_to_deploy_server, :roles => :deploy_server do
    top.upload("y60.tar.gz", "/home/deploy-ir/#{application}", :via=> :scp)    
  end
end
