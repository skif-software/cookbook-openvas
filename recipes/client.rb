#
# Cookbook Name:: openvas
# Recipe:: client
#
# Copyright 2011, Gerald L. Hevener Jr., M.S.
# License: Apache 2.0
#
case node['platform']

  when "ubuntu","debian","linuxmint"

    # Install OpenVAS PPA repo
    include_recipe "openvas::repo"

    # Add required packages to array
    packages = node["openvas"]["openvas-packages"] != nil ? node["openvas"]["openvas-packages"] : %w{ openvas-client openvas-gsa openvas-cli }
    packages.each do |pkg|
    package pkg

    end

  when "redhat","centos","scientific","amazon"

    # Install OpenVAS PPA repo
    include_recipe "openvas::repo"

end

# Manage greenbone-security-assistant
template "/etc/default/openvas-gsa" do
  source "greenbone-security-assistant.erb"
  owner "root"
  group "root"
  mode  "0644"
  notifies :restart, "service[openvas-gsa]"
end

# Enable & start greenbone-security-assistant service
# too soon to start this. we actually need openvas-mkcert in server recipe to create the
# cert and key first
service "openvas-gsa" do
  supports :start => true, :stop => true, :status => true, :restart => true, :reload => true
  action [ :enable ]
end

# Manage openvas-manager
template "/etc/default/openvas-manager" do
  source "openvas-manager.erb"
  owner "root"
  group "root"
  mode  "0644"
  notifies :restart, "service[openvas-manager]"
end

# Enable & start openvas-manager service
service "openvas-manager" do
  supports :start => true, :stop => true, :status => true, :restart => true, :reload => true
  action [ :enable ]
end
