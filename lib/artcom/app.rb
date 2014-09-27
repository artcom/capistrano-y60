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
  after "deploy:setup", "y60:app:setup_directory_structure"
  after "deploy:setup", "y60:app:update_environment"

  after "deploy:finalize_update", "y60:app:generate_watchdog_xml"
  after "deploy:finalize_update", "y60:app:generate_app_settings_js"

  # --------------------------------------------
  # application specific tasks
  # --------------------------------------------
  namespace :y60 do
    namespace :app do

      desc "setup directory structure"
      task :setup_directory_structure, :roles => :app do
        run "mkdir -p #{shared_path}/config"
        run "mkdir -p #{shared_path}/content"
      end

      desc "Set environment variable application content dir"
      task :update_environment, :roles => :app do
        next if find_servers_for_task(current_task).empty?
        run "echo 'export #{application.to_s.upcase.gsub( %r{[\W]+}, '' )}_CONTENT_DIR=#{shared_path}/content' | #{sudo} tee /etc/profile.d/#{application}.sh", :pty => true
      end

      # use as:
      # after 'deploy:setup', 'shared_folder:setup_logrotate'
      desc "Setup logrotate"
      task :setup_logrotate, :roles => :app do
          config_file = <<-CONFIG
#{shared_path}/log/y60.log {
        su microzoo microzoo
        size 1G
        minsize 1k
        copytruncate
        daily
        rotate 14
        compress
        missingok
        notifempty
}
        CONFIG
        put_sudo(config_file, "/etc/logrotate.d/#{application}.conf")
        run "sudo chown root:root /etc/logrotate.d/#{application}.conf"
        run "sudo chmod 644 /etc/logrotate.d/#{application}.conf"
      end

      desc "remove up to 3 days old logfiles"
      task :remove_old_logfiles, :roles => :app do
        run "find #{shared_path}/log/ -mtime +3 -delete"
      end

      desc "generate watchdog.xml"
      task :generate_watchdog_xml, :roles => :app do
        require 'erb'
        location = fetch(:watchdog_xml_dir, "config") + '/watchdog.xml.erb'
        template = File.file?(location) ? File.read(location) : nil
        if template
          config = ERB.new(template)
          myLocation = "#{shared_path}/config/watchdog.xml"
          put config.result(binding), myLocation
          puts "Generated watchdog.xml at #{myLocation}."
        end
      end

      desc "generate app_settings.js"
      task :generate_app_settings_js , :roles => :app do
        require 'erb'
        location = fetch(:app_settings_dir, "config") + '/app_settings.js.erb'
        template = File.file?(location) ? File.read(location) : nil
        if template
          config = ERB.new(template)
          myLocation = "#{shared_path}/config/app_settings.js"
          put config.result(binding), myLocation
          puts "Generated app_settings.js at #{myLocation}."
        end
      end
      desc "rsync content"
      task :rsync_content, :roles => :app do
        servers = find_servers_for_task(current_task)
        servers.each do |server|
          content_dirs.each do |dir|
            system("rsync -uva --delete --exclude '.*' '#{dir}' '#{user}@#{server}:#{shared_path}/content/'")
          end
        end
        sudo "chown -R #{runner}:#{runner} #{deploy_to}"
      end
    end
  end
end

