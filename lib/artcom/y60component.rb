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
  after "deploy:setup", "y60component:setup_directory_structure"
  after "deploy:setup", "y60component:update_ldconfig"
  after "deploy:setup", "y60component:update_environment"


  # --------------------------------------------
  # y60 component specific tasks
  # --------------------------------------------
  namespace :y60component do
    desc "setup directory structure"
    task :setup_directory_structure, :roles => :app do
      y60_components.each {|c|
        run "mkdir -p #{components_install_dir}/#{c}"
      }
    end
    desc "Add component to ldconfig"
    task :update_ldconfig, :roles => :app do
      y60_components.each {|c|
        run "echo '#{components_install_dir}/#{c}/lib/y60/components' | #{sudo} tee /etc/ld.so.conf.d/#{c}.conf", :pty => true
        run "#{sudo} /sbin/ldconfig", :pty => true
      }
    end
    desc "Set environment variable"
    task :update_environment, :roles => :app do
      next if find_servers_for_task(current_task).empty?
      y60_components.each {|c|
        run "echo 'export #{c.to_s.upcase.gsub( %r{[\W]+}, '' )}_DIR=#{components_install_dir}/#{c}/' | #{sudo} tee /etc/profile.d/#{c}.sh", :pty => true
      }
    end

    desc "Copy component"
    task :copy_plugin, :roles => :app do
      y60_components.each {|c|
        top.upload("#{c}.tar.gz", "#{components_install_dir}/", :via=> :scp)
        run "tar -C '#{components_install_dir}/' -xzvf '#{components_install_dir}/#{c}.tar.gz'"
      }
    end
  end
end

