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

    desc "Copy components"
    task :copy_package, :roles => :app do
      y60_components.each {|c|
        run "mkdir -p #{components_install_dir}/#{c}"
        delete_artifact = false
        version = fetch("_#{c}_version".to_sym, "1.0.9")
        target_platform = fetch("_#{c}_target_platform".to_sym, "Linux-x86_64")
        package = fetch("_#{c}_package".to_sym, "#{c}-#{version}-#{target_platform}.tar.gz")
        if not File.file?(package)
          run_locally "scp artifacts@artifacts:pro60/releases/#{package} #{package}"
          delete_artifact = true
        end
        top.upload(package, "#{components_install_dir}", :via=> :scp)
        if delete_artifact
          run_locally "rm -rf #{package}"
        end
        run "tar -C '#{components_install_dir}/#{c}' --exclude include --strip-components 1 -xzvf '#{components_install_dir}/#{package}'"
        run "rm #{components_install_dir}/#{package}"
      }
    end
  end
end

