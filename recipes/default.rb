#
# Cookbook:: chef_tomcat_redhat
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

#  Update your CentOS system
package 'epel-release' do
  action :install
end

#  Install Java
package 'java-1.8.0-openjdk-devel' do
  action :install
end

# Create user abd group tomcat
user "tomcat" do
  manage_home false
  home '/etc/tomcat'
  shell "/bin/nologin"
  comment "Created by Chef"
  system true
  action :create
end
group "tomcat" do
  action :create
  members 'tomcat'
  append true
end

#  Download the latest Apache Tomcat source tar file
remote_file '/tmp/apache-tomcat-9.0.8.tar.gz' do
  source 'https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.8/bin/apache-tomcat-9.0.8.tar.gz'
  owner 'root'
  group 'root'
  mode '0755'
  action :create_if_missing
end

# Create target directory
directory '/opt/tomcat' do
  group 'tomcat'
  recursive true
  action :create
end

# Extract and Install Apache Tomcat Web Server
bash 'extract_apache_tomcat' do
  cwd ::File.dirname('/tmp/apache-tomcat-9.0.8.tar.gz')
  code <<-EOH
    mkdir -p /opt/tomcat
    tar xvf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1
    EOH
  not_if { ::File.exist?('/opt/tomcat/RELEASE-NOTES') }
end

# Setup proper permissions for the target directories
bash 'change_persissions' do
  code <<-EOH
    sudo chgrp -R tomcat /opt/tomcat/conf
    sudo chmod g+rwx /opt/tomcat/conf
    sudo chmod g+r /opt/tomcat/conf/*
    sudo chown -R tomcat /opt/tomcat/logs/ /opt/tomcat/temp/ /opt/tomcat/webapps/ /opt/tomcat/work/
    sudo chgrp -R tomcat /opt/tomcat/bin
    sudo chgrp -R tomcat /opt/tomcat/lib
    sudo chmod g+rwx /opt/tomcat/bin
    sudo chmod g+r /opt/tomcat/bin/*
  EOH
end
%w[ /opt/tomcat/webapps /opt/tomcat/work /opt/tomcat/temp /opt/tomcat/logs ].each do |path|
  directory path do
    owner 'tomcat'
    recursive true
    action :create
  end
end

# Install haveged, a security-related program
package 'haveged' do
  action :install
end

#  Setup a Systemd unit file for Apache Tomcat
template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
end

# Reload daemon
bash 'reload_daemon' do
  code <<-EOH
  systemctl daemon-reload
  EOH
end

# Enable Filewall ports
bash 'firewall' do
  code <<-EOH
  sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp
  sudo firewall-cmd --reload
  EOH
end

# Start and test Apache Tomcat
service 'tomcat' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

