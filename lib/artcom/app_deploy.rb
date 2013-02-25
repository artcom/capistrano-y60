# Required base libraries
require 'artcom/capistrano-y60'
require 'railsless-deploy'

# Bootstrap Capistrano instance
configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :app_deploy do

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
  end
end

