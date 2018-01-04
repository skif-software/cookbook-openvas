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
    packages = node["openvas"]["openvas-packages"] != nil ? node["openvas"]["openvas-packages"] : %w{ openvas-client greenbone-security-assistant openvas-cli }
    # %w{ openvas-cli greenbone-security-assistant openvas-cli }.each do |pkg|
    packages.each do |pkg|
    package pkg

    end    

  when "redhat","centos","scientific","amazon"

    # Install OpenVAS PPA repo
    include_recipe "openvas::repo"

end

# Manage greenbone-security-assistant
template "/etc/default/greenbone-security-assistant" do
  source "greenbone-security-assistant.erb"
  owner "root"
  group "root"
  mode  "0644"
  notifies :restart, "service[greenbone-security-assistant]"
end

# Enable & start greenbone-security-assistant service
# too soon to start this. we actually need openvas-mkcert in server recipe to create the
# cert and key first
service "greenbone-security-assistant" do
  supports :start => true, :stop => true, :status => true, :restart => true, :reload => true
  action [ :enable ]
end
