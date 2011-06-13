#!/bin/bash
source "/usr/local/rvm/scripts/rvm"
export GEM_PATH="$(rvm gemdir)" 
export GEM_HOM="$(rvm gemdir)" 
chef-solo  -c /etc/chef/solo.rb -j /tmp/chef.json -r http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz\
