# chef tomcat redhat

1. Install Apache Tomcat Web Server

2. The cookbook on the instruction web page 
https://www.vultr.com/docs/how-to-install-apache-tomcat-8-on-centos-7

3. 3. Requirements
3.1 Platform
Redhat 7
Centos 7

3.2 Chef Release
Chef 12.14+

4. Steps
4.1 Update your CentOS system
4.2 Install Java
4.3 Create a dedicated user and group for Apache Tomcat
4.4 Download and install the latest Apache Tomcat
4.5 Setup proper permissions
4.6 Setup a Systemd unit file for Apache Tomcat
4.7 Install haveged, a security-related program
4.8 Start and test Apache Tomcat
4.9 Configure the Apache Tomcat web management interface

5. Resources
5.1 Update your CentOS system
package 'epel-release'

5.2 Install Java
package 'java-1.8.0-openjdk-devel'

5.3 Create user abd group tomcat
user "tomcat"
group "tomcat"

5.4 Download the latest Apache Tomcat source tar file
remote_file '/tmp/apache-tomcat-9.0.8.tar.gz'

5.5 Create target directory
directory '/opt/tomcat'

5.6 Extract and Install Apache Tomcat Web Server
bash 'extract_apache_tomcat'

5.6 Setup proper permissions for the target directories
bash 'change_persissions'

5.7 Setup a Systemd unit file for Apache Tomcat
template '/etc/systemd/system/tomcat.service'

5.8 Install haveged, a security-related program
package 'haveged'

5.9 Reload daemon
bash 'reload_daemon'

5.10 Enable Filewall ports
bash 'firewall'

5.11 Start and test Apache Tomcat
service 'tomcat'






