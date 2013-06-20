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

      desc "generate watchdog.xml"
      task :generate_watchdog_xml, :roles => :app do
        require 'erb'
        default_template = <<-XML
    <WatchdogConfig/>
        XML
        location = fetch(:watchdog_xml_dir, "config") + '/watchdog.xml.erb'
        template = File.file?(location) ? File.read(location) : default_template
        config = ERB.new(template)
        myLocation = "#{shared_path}/config/watchdog.xml"
        put config.result(binding), myLocation
        puts "Generated watchdog.xml at #{myLocation}."
      end

      desc "generate app_settings.js"
      task :generate_app_settings_js , :roles => :app do
        require 'erb'
        js_template = <<-JS
    var app_settings = app_settings || {};
        JS
        location = fetch(:app_settings_dir, "config") + '/app_settings.js.erb'
        template = File.file?(location) ? File.read(location) : js_template
        config = ERB.new(template)
        myLocation = "#{shared_path}/config/app_settings.js"
        put config.result(binding), myLocation
        puts "Generated app_settings.js at #{myLocation}."
      end
      desc "rsync content"
      task :rsync_content, :roles => :app do
        servers = find_servers_for_task(current_task)
        servers.each do |server|
          content_dirs.each do |dir|
            system("rsync -uva --delete --exclude '.*' '#{dir}' '#{user}@#{server}:#{shared_path}/content/'")
          end
        end
      end

      desc "Set environment variable application content dir"
      task :update_environment, :roles => :app do
        next if find_servers_for_task(current_task).empty?
        run "echo 'export #{application.to_s.upcase.gsub( %r{[\W]+}, '' )}_CONTENT_DIR=#{shared_path}/content' | #{sudo} tee /etc/profile.d/#{application}.sh", :pty => true
      end
    end
  end
end

