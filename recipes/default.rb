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

#bash 'install_apache_tomcat' do
#  user 'root'
#  cwd '/tmp'
#  code <<-EOH
#  mkdir /opt/tomcat
#  wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.8/bin/apache-tomcat-9.0.8.tar.gz
#  tar -zxf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1
#  EOH
#end
#

remote_file '/tmp/apache-tomcat-9.0.8.tar.gz' do
  source 'https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.8/bin/apache-tomcat-9.0.8.tar.gz'
  owner 'root'
  group 'root'
  mode '0755'
  action :create_if_missing
end

bash 'extract_apache_tomcat' do
  cwd ::File.dirname('/tmp/apache-tomcat-9.0.8.tar.gz')
  code <<-EOH
    mkdir -p /opt/tomcat
    tar xvf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1
    EOH
  not_if { ::File.exist?('/opt/tomcat/RELEASE-NOTES') }
end
