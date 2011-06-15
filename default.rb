# After creating your AWS servers and setting up your ssh key
#
namespace :chef_client do
  desc "Make your chef clients"
  task :doit , :roles=> :c_client do
    servers.hostname
    servers.upgrade
    servers.build
    ruby.rvm
    ruby.rvm
    ruby.chef.client
  end
end
#
#
namespace :chef_server do
  desc "Make your chef server"
  task :doit , :roles=> :c_server do
    servers.hostname 
    servers.upgrade
    servers.build
    ruby.rvm
    ruby.rvm
    ruby.chef.server
  end
  desc "Setup Knife on server"
  task :knifesetup, :roles=> :c_server  do
    run "mkdir -p #{user_home_dir}/.chef" 
    run "#{sudo} cp /etc/chef/validation.pem /etc/chef/webui.pem #{user_home_dir}/.chef ;  #{sudo} chown -R $USER #{user_home_dir}/.chef"
    run "knife configure --defaults --yes --repository . "
    run "knife client list"
  end
end
