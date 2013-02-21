namespace :watchdog_deploy do

  desc "Setup environment variable watchdog 'WATCHDOG_DIR"
  task :update_environment, :roles => :app do
    next if find_servers_for_task(current_task).empty?
    run "echo 'export WATCHDOG_DIR=#{shared_path}/watchdog/bin' | #{sudo} tee /etc/profile.d/watchdog.sh", :pty => true
  end
end

