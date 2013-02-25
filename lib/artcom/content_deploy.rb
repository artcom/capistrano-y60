# Required base libraries
require 'artcom/capistrano-y60'
require 'railsless-deploy'

# Bootstrap Capistrano instance
configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :content_deploy do

    desc "rsync content"
    task :rsync_content, :roles => :app do
      servers = find_servers_for_task(current_task)
      servers.each do |server|
        system("rsync -uva --delete --exclude '.*' '#{content_dir}' '#{user}@#{server}:#{shared_path}/content/'")
      end
    end

    desc "rsync content to deployment server"
    task :rsync_content_deploy_server, :roles => :deploy_server do
      servers = find_servers_for_task(current_task)
      servers.each do |server|
        system("rsync -uva --delete --exclude '.*' '#{content_dir}' '#{user}@#{server}:/home/deploy-ir/#{application}'")
      end
    end

    desc "Set environment variable CONTENT_DIR"
    task :update_environment, :roles => :app do
      next if find_servers_for_task(current_task).empty?
      run "echo 'export #{application.to_s.upcase}_CONTENT_DIR=#{shared_path}/content' | #{sudo} tee /etc/profile.d/#{application}.sh", :pty => true
    end
  end
end
