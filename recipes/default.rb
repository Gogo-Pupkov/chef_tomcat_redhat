#
# Cookbook:: chef_tomcat_redhat
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package 'epel-release' do
  action :install
end

package 'java-1.8.0-openjdk-devel' do
  action :install
end

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

directory '/opt/tomcat' do
  group 'tomcat'
  recursive true
  action :create
end

#directory '/opt/tomcat/test' do
#  mode '040'
#  recursive true
#  action :create
#end
#
bash 'change_persissions' do
  cwd ::File.dirname('/opt/tomcat')
  code <<-EOH
  sudo chgrp -R tomcat conf
  sudo chmod g+rwx conf
  sudo chmod g+r conf/*
  sudo chown -R tomcat logs/ temp/ webapps/ work/
  sudo chgrp -R tomcat bin
  sudo chgrp -R tomcat lib
  sudo chmod g+rwx bin
  sudo chmod g+r bin/*
  EOH
end

package 'haveged' do
  action :install
end

%w[ /opt/tomcat/webapps /opt/tomcat/work /opt/tomcat/temp /opt/tomcat/logs ].each do |path|
  directory path do
    owner 'tomcat'
    recursive true
    action :create
  end
end

template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
end

bash 'change_persissions' do
  code <<-EOH
  systemctl daemon-reload
  EOH
end

bash 'firewall' do
  code <<-EOH
  sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp
  sudo firewall-cmd --reload
  EOH
end

service 'tomcat' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
