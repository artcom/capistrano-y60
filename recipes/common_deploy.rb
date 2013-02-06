namespace :common_deploy do

  desc "Set environment variable COMMON_DIR"
  task :update_environment, :roles => :app do
    next if find_servers_for_task(current_task).empty?
    run "echo 'export #{application.upcase.gsub("-","_")}_DIR=#{current_path}' | #{sudo} tee /etc/profile.d/#{application}.sh", :pty => true
  end
  desc "remove logfiles"
  task :remove_logfiles, :roles => :app do
    next if find_servers_for_task(current_task).empty?
    run "rm -rf #{shared_path}/log/*", :pty => true
  end

  desc "collect logfiles"
  task :collect_logfiles, :roles => :app do
    servers = find_servers_for_task(current_task)
    servers.each do |server|
      run "tar -C '#{shared_path}' -czvf '#{application}_#{server}_logs.tar.gz' ./log", :pty => true, :hosts => server
      top.download("#{application}_#{server}_logs.tar.gz", ".", :via=> :scp, :hosts => server)
    end
  end
end
