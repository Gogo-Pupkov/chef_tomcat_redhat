#
# Cookbook:: chef_tomcat_redhat
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user "tomcat" do
  manage_home false
  home '/etc/tomcat'
  shell "/bin/nologin"
  comment "Created by Chef"
  system true
  provider Chef::Provider::User::Useradd
  action :create
end

group "tomcat" do
  action :create
  members 'tomcat'
  append true
end

