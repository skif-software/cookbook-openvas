#
# Cookbook Name:: openvas
# Recipe:: server-source
#
# Copyright 2014, Gerald L. Hevener Jr., M.S.
# License: Apache 2.0
#

## dkw: actually mostly just notes on installing from source so far


# install development libraries
# do an apt-get update first
%w{ rsync wget curl pkg-config libssh-dev libgnutls-dev libglib2.0-dev libpcap-dev libgpgme11-dev uuid-dev bison libksba-dev cmake libldap-2.4-2 }.each do |devpkg|
  package devpkg
end

# Download OpenVAS libraries.
remote_file "#{Chef::Config[:file_cache_path]}/openvas-libraries-7.0.4.tar.gz" do
  source 'http://wald.intevation.org/frs/download.php/1722/openvas-libraries-7.0.4.tar.gz'
  action :create_if_missing
end

# use checkinstall?
# install the wmi libraries and patches?
# find and install wincmd?
# cmake
# make install


# Download OpenVAS scanner.
remote_file "#{Chef::Config[:file_cache_path]}/openvas-scanner-4.0.3.tar.gz" do
  source 'http://wald.intevation.org/frs/download.php/1726/openvas-scanner-4.0.3.tar.gz'
  action :create_if_missing
end

# use checkinstall?
# cmake
# make install
# openvas-mkcert
# openvas-nvt-sync


# Download OpenVAS manager.
remote_file "#{Chef::Config[:file_cache_path]}/openvas-manager-5.0.4.tar.gz" do
  source 'http://wald.intevation.org/frs/download.php/1730/openvas-manager-5.0.4.tar.gz'
  action :create_if_missing
end

# Download OpenVAS GSA ( Greenbone Security Assistant ).
remote_file "#{Chef::Config[:file_cache_path]}/greenbone-security-assistant-5.0.3.tar.gz" do
  source 'http://wald.intevation.org/frs/download.php/1734/greenbone-security-assistant-5.0.3.tar.gz'
  action :create_if_missing
end

# Download OpenVAS CLI ( Command Line Interface ).
remote_file "#{Chef::Config[:file_cache_path]}/openvas-cli-1.3.0.tar.gz" do
  source 'http://wald.intevation.org/frs/download.php/1633/openvas-cli-1.3.0.tar.gz'
  action :create_if_missing
end

