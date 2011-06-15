namespace :servers do
  desc "Set hostname" # Makes life easier when your hoping around trying to fix things
  task :hostname do
    # Easy to do via perl since ruby isn't installed yet and shorter than a template
    run "#{sudo} hostname $CAPISTRANO:HOST$ ; #{sudo} perl -i -p -e s'/ localhost.*$/ localhost\ $CAPISTRANO:HOST$/'  /etc/hosts"
  end
  desc "Upgrade Ubuntu"
  task :upgrade  do
    run "#{sudo} hostname $CAPISTRANO:HOST$" 
    run "#{sudo} apt-get -q update"
    run "#{sudo} apt-get -q -y upgrade"
    run "#{sudo} apt-get -q -y dist-upgrade"
  end

  desc "Install build requirements"
  task :build do
    run "#{sudo} apt-get -q update"
    run "#{sudo} apt-get -q -y install build-essential bison \
        openssl \
        curl \
        git-core \
        autoconf \
        openssl \
        libreadline6 \
        libreadline6-dev  \
        libsqlite3-dev \
        libssl-dev \
        libyaml-dev \
        libmysqlclient16 \
        libpq-dev \
        libsqlite3-0 \
        libsqlite3-dev \
        libxml2-dev \
        libxslt-dev \
        sqlite3 \
        libc6-dev ncurses-dev \
        zlib1g \
        zlib1g-dev"
  end
  desc "Setup bash for rvm"
  task :bash do
    run "mkdir -p #{user_home_dir}/cap-files/bin #{user_home_dir}/cap-files/etc/skel"
    upload("./servers/files/etc/bash.bashrc", "#{user_home_dir}/cap-files/etc/bash.bashrc")
    upload "./servers/files/etc/skel/bashrc", "#{user_home_dir}/cap-files/etc/skel/bashrc"
    # Fix a few bash files   
    run "cat #{user_home_dir}/cap-files/etc/skel/bashrc > #{user_home_dir}/.bashrc" 
    run "#{sudo} cp #{user_home_dir}/cap-files/etc/bash.bashrc  /etc/bash.bashrc"
    run "#{sudo} cp #{user_home_dir}/cap-files/etc/skel/bashrc /etc/skel/.bashrc" 
    run "#{sudo} cp #{user_home_dir}/cap-files/etc/skel/bashrc /root/.bashrc" 
  end
  desc "Replace chef init scripts"
  task :init do
    upload "./servres/files/etc/init.d/chef-expander", "#{user_home_dir}/cap-files/etc/init.d/chef-expander"
    upload "./servres/files/etc/init.d/chef-server", "#{user_home_dir}/cap-files/etc/init.d/chef-server"
    upload "./servres/files/etc/init.d/chef-server-webui", "#{user_home_dir}/cap-files/etc/init.d/chef-server-webui"
    upload "./servres/files/etc/init.d/chef-solr", "#{user_home_dir}/cap-files/etc/init.d/chef-solr"
    upload "./servres/files/bin/update-chef-init.sh", "#{user_home_dir}/cap-files/bin/update-chef-init.sh"
    # Fix the init.d scripts for chef server
    run "sudo cp #{user_home_dir}/cap-files/etc/init.d/chef-expander  /etc/init.d/chef-expander"
    run "sudo cp #{user_home_dir}/cap-files/etc/init.d/chef-server /etc/init.d/chef-server"
    run "sudo cp #{user_home_dir}/cap-files/etc/init.d/chef-server-webui /etc/init.d/chef-server-webui"
    run "sudo cp #{user_home_dir}/cap-files/etc/init.d/chef-solr  /etc/init.d/chef-solr"
  end
end

namespace :ubuntu do
  desc "Install chef ubuntu packages"
  task :chef, :roles=> :c_client do
    run "echo \"deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main\" > /tmp/opscode.list"
    run "#{sudo} cp /tmp/opscode.list /etc/apt/sources.list.d"
    run "mkdir -p #{user_home_dir}/cap-files/etc/chef"
    run "wget -qO - http://apt.opscode.com/packages@opscode.com.gpg.key | sudo apt-key add - "
      template = File.read(File.join(File.dirname(__FILE__), "./files/etc/chef/server.rb.erb"))
      buffer   = ERB.new(template).result(binding)
      put buffer, "#{user_home_dir}/cap-files/etc/chef/server.rb"
    run "#{sudo} mkdir -p /etc/chef" 
    run "#{sudo} cp #{user_home_dir}/cap-files/etc/chef/server.rb /etc/chef/server.rb"
    run "#{sudo} apt-get update"
    run "#{sudo} apt-get -y upgrade"
    run "#{sudo} apt-get -y install chef"
  end
end
