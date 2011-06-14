# Ruby setup using rvm so chef and other ruby items work as expected.
#  There may be an issue with  GEM_PATH and GEM_HOME
#
namespace :ruby do
  desc "Install rvm for ubuntu user"
  task :rvm , :roles=> :c_client do
    server.bash # Setup bash to work with rvm
    upload "./ruby/files/setup-rvm.sh", "#{user_home_dir}/cap-files/bin/setup-rvm.sh"
    run "chmod 755  #{user_home_dir}/cap-files/bin/setup-rvm.sh ; #{sudo} #{user_home_dir}/cap-files/bin/setup-rvm.sh"
    run "rvm install 1.9.2"
    run "rvm --default use 1.9.2"
    run "ruby --version"
    run "GEM_PATH=\"$(rvm gemdir)\" GEM_HOME=\"$(rvm gemdir)\" rvm rubygems current"
  end
  namespace :chef do
    desc "Required chef base" 
    task :base , :roles=> :c_client do
      run "#{sudo} mkdir -p /etc/chef ; mkdir -p #{user_home_dir}/cap-files/etc/chef"
      run "GEM_PATH=\"$(rvm gemdir)\" GEM_HOME=\"$(rvm gemdir)\" gem install chef --version=0.10 --no-ri --no-rdoc"
      run "GEM_PATH=\"$(rvm gemdir)\" GEM_HOME=\"$(rvm gemdir)\" gem install ohai --no-ri --no-rdoc"
      upload "./ruby/files/chef/install-chef.sh", "#{user_home_dir}/cap-files/install-chef.sh"
      run "chmod 755 #{user_home_dir}/cap-files/install-chef.sh"
      upload "./ruby/files/chef/solo.rb", "#{user_home_dir}/cap-files/etc/chef/solo.rb"
      run "#{sudo} cp #{user_home_dir}/cap-files/etc/chef/solo.rb /etc/chef"
    end
    desc "Create server.rb configuration file"
    task :create_conf, :roles => :c_server do
      template = File.read(File.join(File.dirname(__FILE__), "./files/chef/server.rb.erb"))
      buffer   = ERB.new(template).result(binding)
      put buffer, "#{user_home_dir}/cap-files/etc/chef/server.rb"
    end
    desc "Install chef server"
    task :server , :roles=> :c_server do
      ruby.chef.base # Run the chef base setup
      # Need to verify what the ownership of these directories needs to be.
      run "#{sudo} mkdir -p /var/chef/{nodes,openid/store,openid/cstore,search_index,roles,cookbooks,site-cookbooks}"
      upload "./ruby/files/chef/chef-server.json", "#{user_home_dir}/cap-files/chef-server.json"
      run "ln -sf #{user_home_dir}/cap-files/chef-server.json /tmp/chef.json"
      run "#{sudo} #{user_home_dir}/cap-files/install-chef.sh" # sudo required this
      servers.init # Fix the init.d scripts that are missing the path to rvm ruby
      run "sudo rabbitmqctl add_vhost /chef"
      run "sudo rabbitmqctl add_user chef testing"
      run "sudo rabbitmqctl set_permissions -p /chef chef \".*\" \".*\" \".*\""
    end
    desc "Install chef client"
    task :client , :roles=> :c_client do
      ruby.chef.base # Run the chef base setup
      upload "./ruby/files/chef/chef-client.json", "#{user_home_dir}/cap-files/chef-client.json"
      run "ln -sf #{user_home_dir}/cap-files/chef-client.json /tmp/chef.json"
      run "#{sudo} #{user_home_dir}/cap-files/install-chef.sh" # sudo required this
    end
  end
end