#
# Cookbook Name:: openvas
# Recipe:: server
#
# Copyright 2011, Gerald L. Hevener Jr., M.S.
# License: Apache 2.0
#

# Install OpenVAS PPA repo & client
include_recipe "openvas::default"
include_recipe "openvas::client"
include_recipe "openvas::nmap"
include_recipe "openvas::openvasknife"

# Install required Ruby gems
%w{ openvas-omp }.each do |gempkg|
  gem_package gempkg do
    action :install
  end
end

# Install OpenVAS server packages
case node['platform']
when "ubuntu","debian","linuxmint"
  %w{ coreutils texlive-latex-base texlive-latex-extra texlive-latex-recommended htmldoc nsis
	openvas-manager openvas-scanner openvas-administrator sqlite3 xsltproc wget alien nikto gnupg }.each do |pkg|
    package pkg
  end  
  # drop files in place missing from openvas-manager deb/ubuntu packages
  directory "/usr/share/openvas/cert" do
    mode  "00755"
    owner "root"
    group "root"
    recursive true
  end

  %w{ cert_db_init.sql dfn_cert_getbyname.xsl dfn_cert_update.xsl }.each do |omfile|
    cookbook_file omfile do
      owner "root"
      group "root"
      mode  "00644"
      path  "/usr/share/openvas/cert/#{omfile}"
      source "openvas-manager/#{omfile}"
    end
  end

when "redhat","centos","scientific","amazon"
  %w{ nikto htmldoc tetex tetex-dvips tetex-fonts tetex-latex tetex-tex4ht
        passivetex }.each do |pkg|
      package pkg
  end  
    # Install Nmap version 6
    include_recipe "openvas::nmap"

    # Install Alien
  execute "install-alien-on-redhat" do
    command "rpm -Uvh ftp://ftp.pbone.net/mirror/ftp.sourceforge.net/pub/sourceforge/p/po/postinstaller/data/alien-8.85-2.noarch.rpm"
    action :run
    not_if "rpm -qa |grep alien"
  end

    # Implement workaround for OpenVAS v5 bug
      execute "install-openvas-v4-x86_64" do
        command "rpm -Uvh http://www6.atomicorp.com/channels/atomic/centos/5/x86_64/RPMS/openvas-libraries-4.0.2-1.el5.art.x86_64.rpm;
                 rpm -Uvh http://www6.atomicorp.com/channels/atomic/centos/5/x86_64/RPMS/openvas-manager-2.0.4-3.el5.art.x86_64.rpm;
                 rpm -Uvh http://www6.atomicorp.com/channels/atomic/centos/5/x86_64/RPMS/xerces-c-2.8.0-4.el5.art.x86_64.rpm;
                 rpm -Uvh http://www6.atomicorp.com/channels/atomic/centos/5/x86_64/RPMS/xalan-c-1.10.0-6.el5.art.x86_64.rpm;
                 rpm -Uvh http://www6.atomicorp.com/channels/atomic/centos/5/x86_64/RPMS/ovaldi-5.6.4-1.el5.art.x86_64.rpm;
                 rpm -Uvh http://www6.atomicorp.com/channels/atomic/centos/5/x86_64/RPMS/openvas-scanner-3.2.2-3.el5.art.x86_64.rpm;
                 rpm -Uvh http://www6.atomicorp.com/channels/atomic/centos/5/x86_64/RPMS/openvas-cli-1.1.3-1.el5.art.x86_64.rpm;
                 rpm -Uvh http://www6.atomicorp.com/channels/atomic/centos/5/x86_64/RPMS/openvas-glib2-2.22.5-1.el5.art.x86_64.rpm;
                 rpm -Uvh http://www6.atomicorp.com/channels/atomic/centos/5/x86_64/RPMS/greenbone-security-assistant-2.0.1-4.el5.art.x86_64.rpm;
                 rpm -Uvh http://www6.atomicorp.com/channels/atomic/centos/5/x86_64/RPMS/openvas-1.0-0.5.el5.art.noarch.rpm;
                 rpm -Uvh http://www6.atomicorp.com/channels/atomic/centos/5/x86_64/RPMS/openvas-administrator-1.1.1-2.el5.art.x86_64.rpm;"
        action :run
        only_if "uname -a |grep x86_64"
        not_if "rpm -qa |grep openvas"
      end
    
      # Implement workaround for package libmicrohttpd not being compiled
      # with SSL support on Redhat.
      script "start-gsad-service" do
        interpreter "bash"
        user "root"
        cwd "/tmp"
        code <<-EOH
        /usr/sbin/gsad --http-only --port #{node['openvas']['gsad_port']}
        EOH
        not_if "ps aux |grep gsad |egrep -v grep"
      end
 
  end 

    # A bug in OpenVAS v5 causes it to fail to start on redhat.
    # Until fixed upstream, redhat users will get OpenVAS v4 instead. 
    #%w{ openvas }.each do |pkg|
    #package pkg 
  #end
  #execute "install-openvas-redhat" do
  #command "yum makecache; yum -y install openvas"
  #action :run
  #not_if "rpm -qa |grep openvas"
  #end

#end

cookbook_file "/usr/local/bin/openvas-check-setup" do
  source "openvas-check-setup"
  mode "0744"
end

# Create OpenVAS certificate
execute "openvas-mkcert" do
  command "openvas-mkcert -q"
  action :run
  not_if "test -e /var/lib/openvas/CA/cacert.pem"
end

# Create /var/lib/openvas/plugins
directory "/var/lib/openvas/plugins" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

# Install and sign OpenVAS Transfer Integrity Certificate to support signed NVTs and reports
Chef::Log.warn("node.openvas.nasl_no_signature = #{node['openvas']['nasl_no_signature_check']}")
Chef::Log.warn("is node.openvas.nasl_no_signature a string? #{node['openvas']['nasl_no_signature_check'].is_a? String}")

directory "/etc/openvas/gnupg" do
  owner "root"
  group "root"
  mode "0700"
  action :create
  only_if { node['openvas']['nasl_no_signature_check'] == "no" }
end

# generate local signing key
template node['openvas']['gpg']['batch']['config'] do
  source "gpg_batch_config.erb"
  mode  "0440"
  owner "root"
  group "root"
  variables({
     :key_type => node['openvas']['gpg']['key']['type'],
     :key_length => node['openvas']['gpg']['key']['length'],
     :name_real => node['openvas']['gpg']['name']['real'],
     :name_comment => node['openvas']['gpg']['name']['comment'],
     :name_email => node['openvas']['gpg']['name']['email'],
     :expire_date => node['openvas']['gpg']['expire']['date']
  })
  only_if { node['openvas']['nasl_no_signature_check'] == "no" }
end

package "rng-tools" do
  only_if { node['openvas']['nasl_no_signature_check'] == "no" }
end

# gotta make sure rngd is service is disabled and stopped, otherwise we can't start it below

execute "seed-random-number-generator" do
  command "rngd -r /dev/urandom"
  only_if { node['openvas']['nasl_no_signature_check'] == "no" }
end

execute "generate-openvas-gpg-key" do
  command "gpg --homedir=/etc/openvas/gnupg --gen-key --batch #{node['openvas']['gpg']['batch']['config']}"
    only_if { node['openvas']['nasl_no_signature_check'] == "no" }
    only_if "gpg --list-keys --homedir=/etc/openvas/gnupg | grep #{node['openvas']['gpg']['name']['comment']}"
end

# add Transfer Integrity Certificate
#   only_if { node['openvas']['nasl_no_signature_check'] == "no" }

# Trust Transfer Integrity Certificate
#   only_if { node['openvas']['nasl_no_signature_check'] == "no" }


# Initial update OpenVAS network vulnerability tests
#  this takes a long time so subsequent updats done by a daily cron job
execute "openvas-nvt-sync" do
  command "openvas-nvt-sync; sleep 5m"
  action :run
  not_if "COUNT=`ls -alh /var/lib/openvas/plugins/a* |wc -l`; [ $COUNT -gt 50 ] && echo true; "
end

# Create SSL client certificate for user om
execute "openvas-mkcert-client" do
  command "openvas-mkcert-client -n om -i"
  action :run
  not_if "test -d /var/lib/openvas/users/om"
end

# Migrate/rebuild database on 1st run
execute "openvassd" do
  command "openvassd"
  user	  "root"
  action :run
  not_if "netstat -nlp |grep openvassd"
end

# Initial sync of the SCAP data
directory "/var/lib/openvas/scap-data/private" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

  # openvas-scapdata-sync is broken in version 4.x of openvas-manager,
  # so replace the script if we have a broken one
  # see http://osdir.com/ml/openvas-security-network/2013-10/msg00033.html
cookbook_file "/usr/sbin/openvas-scapdata-sync" do
  owner "root"
  group "root"
  mode  "00755"
  source "openvas-manager/openvas-scapdata-sync.4fixed"
  only_if "openvas-scapdata-sync --version | grep ^4"
end

 # doesn't seem to take more than 15 sec, so maybe we can forgo the cron job and just let
 #  chef-client runs do this every time?
execute "openvas-scapdata-sync" do
  command "openvas-scapdata-sync"
  not_if { ::File.exist?("/var/lib/openvas/scap-data/scap.db") } 
end
 

# Rebuild openvasmd-rebuild
execute "openvasmd-rebuild" do
  command "openvasmd --rebuild"
  user    "root"
  action :run
  not_if "test -d /var/lib/openvas/users/admin"
end

# Initial sync of CERT db. This is quick, so we can let chef do this every run.
execute "openvas-certdata-sync"

# Execute killall openvassd
execute "killall-openvassd" do
  command "killall openvassd"
  user    "root"
  action :run
  not_if "test -d /var/lib/openvas/users/admin"
end

# Sleep for 15 seconds
execute "sleep" do
  command "sleep 15"
  user    "root"
  action :run
  not_if "test -d /var/lib/openvas/users/admin"
end

# Enable & start openvas-scanner service
service "openvas-scanner" do
  supports :start => true, :stop => true, :status => true, :restart => true
  action [ :enable, :start ]
end

# Enable & start openvas-manager service
service "openvas-manager" do
  supports :start => true, :stop => true, :status => true, :restart => true, :reload => false, :condrestart => true
  action [ :enable, :start ]
end

# Enable & start openvas-administrator service
service "openvas-administrator" do
  supports :start => true, :stop => true, :status => true, :restart => true, :reload => false, :condrestart => true
  action [ :enable, :start ]
end


# Generate random password, assign to admin openvas account
# and write password to /tmp/openvas_admin_pass.txt.
ruby_block "gen_rand_openvas_pass" do
  block do
    def newpass( len )
      
      # Set list of chars to include in pseudo-random password
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      newpass = ""
      1.upto(len) { |i| newpass << chars[rand(chars.size)] }
      return newpass

    end

    # Set password length to 12 chars
    pass = newpass(12)

    # Write random password to file
    f = File.new( "/etc/openvas/openvas_admin_pass.txt", "w" )
    f.puts( "This is username & password for the OpenVAS admin account.\n" )
    f.puts( "Generated by Opscode Chef!\n" )
    f.puts( "Username: admin Password: #{pass}" )
    f.close

    system( "openvasad -c add_user -n admin -r Admin -w #{pass}" )
    system( "chmod 0640 /etc/openvas/openvas_admin_pass.txt" )

  end
  action :create
  not_if "test -e /etc/openvas/openvas_admin_pass.txt"
end

# Add template for /etc/openvas/gsad_log.conf
template "/etc/openvas/gsad_log.conf" do
  source "gsad_log.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  not_if "test -f /etc/openvas/gsad_log.conf"
  notifies :reload, "service[greenbone-security-assistant]", :immediately
end

# Add template for /etc/openvas/openvasad_log.conf
template "/etc/openvas/openvasad_log.conf" do
  source "openvasad_log.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[openvas-administrator]", :immediately
end

# Add template for /etc/openvas/openvasmd_log.conf
template "/etc/openvas/openvasmd_log.conf" do
  source "openvasmd_log.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[openvas-manager]", :immediately
end

# Add template for /etc/openvas/openvassd.conf
template "/etc/openvas/openvassd.conf" do
  source "openvassd.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[openvas-scanner]", :immediately
  variables ({
    :nasl_no_signature_check => node['openvas']['nasl_no_signature_check']
  })
end

# Add template for /etc/openvas/openvassd.rules
template "/etc/openvas/openvassd.rules" do
  source "openvassd.rules.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[openvas-scanner]", :immediately
end

# Check if Greenbone scan configs are enabled
if node['openvas']['enable_greenbone_scan_configs'] == "yes"

  # Include Greenbone scan configs
  include_recipe "openvas::greenbone_scan_configs"
end
