#
# Cookbook Name:: openvas 
# Attributes:: default 
# Copyright 2011, Gerald L. Hevener, Jr, M.S.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set yes to append CRON job to crontab to update NVTs
default['openvas']['enable_nvt_updates_from_cron'] = "no"

# Set Perl location. Not used if ['openvas']['enable_nvt_updates_from_cron'] = 'no'
default['openvas']['which_perl'] = "/usr/bin/perl"

# Set TCP port for the gsad service
default['openvas']['gsad_port'] = '9392'

# Set TCP port for the openvas-manager service
default['openvas']['manager_port'] = '9390'

# Set ipaddress for the openvas-manager service listen to
default['openvas']['manager_ipaddress'] = '127.0.0.1'

# Set to yes to enable Greenbone scan configs
default['openvas']['enable_greenbone_scan_configs'] = "no"

# Set to no to enable NVT signature check.
default['openvas']['nasl_no_signature_check'] = "yes"

# Target to create ( e.g. Server you want to scan )
default['openvas']['target_to_create'] = 'scanme.example.tld'

# Random pass is generated in server.rb
default['openvas']['openvas_admin_pass'] = ''

# Vesion of libraries to install.
default['openvas']['libraries_version'] = '7.0.4'

# Vesion of scanner to install.
default['openvas']['scanner_version'] = '4.0.3'

# Vesion of manager to install.
default['openvas']['manager_version'] = '5.0.4'

# Vesion of GSA ( Greenbone Security Assistant ) to install.
default['openvas']['gsa_version'] = '5.0.3'

# Vesion of CLI ( Command Line Interface ) to install.
default['openvas']['cli_version'] = '1.3.0'

# Libraries download URL.
default['openvas']['libraries_url'] = 'http://wald.intevation.org/frs/download.php/1722/openvas-libraries-7.0.4.tar.gz'

# Scanner download URL.
default['openvas']['scanner_url'] = 'http://wald.intevation.org/frs/download.php/1726/openvas-scanner-4.0.3.tar.gz'

# Manager downoad URL.
default['openvas']['manager_url'] = 'http://wald.intevation.org/frs/download.php/1730/openvas-manager-5.0.4.tar.gz'

# GSA ( Greenboon Security Assistant ) download URL.
default['openvas']['gsa_url'] = 'http://wald.intevation.org/frs/download.php/1734/greenbone-security-assistant-5.0.3.tar.gz'

# CLI ( Command Line Interface to install ) download URL.
default['openvas']['gsa_url'] = 'http://wald.intevation.org/frs/download.php/1633/openvas-cli-1.3.0.tar.gz'

default['openvas']['openvas-repo-uri'] = ''
default['openvas']['openvas-repo-keyserver'] = ''
default['openvas']['openvas-repo-key'] = ''
