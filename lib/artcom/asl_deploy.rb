# Required base libraries
require 'artcom/capistrano-y60'
require 'railsless-deploy'

# Bootstrap Capistrano instance
configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :asl_deploy do

    desc "Add asl/lib to ldconfig"
    task :update_ldconfig, :roles => :app do
      run "echo '#{shared_path}/asl/lib' | #{sudo} tee /etc/ld.so.conf.d/asl.conf", :pty => true
      run "#{sudo} /sbin/ldconfig", :pty => true
    end
  end
end

