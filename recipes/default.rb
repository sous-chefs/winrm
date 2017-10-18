#
# Cookbook Name:: winrm
# Recipe:: default
#
# Copyright 2012, Peter Crossley
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
#

powershell 'search-for-thumbprint' do
  cwd Chef::Config[:file_cache_path]
  code "Get-childItem cert:\\LocalMachine\\Root\\ | Select-String -pattern #{node['fqdn']} | Select-Object -first 1 -ExpandProperty line | % { $_.SubString($_.IndexOf('[Thumbprint]')+ '[Thumbprint]'.Length).Trim()} | Out-File -Encoding \"ASCII\" winrm.thumbprint"
  only_if { node['winrm']['thumbprint'].nil? && node['winrm']['https'] }
  notifies :create, 'file[fix-perms-thumbprint]', :immediately
end

file 'fix-perms-thumbprint' do
  action :nothing
  path "#{Chef::Config[:file_cache_path]}\\winrm.thumbprint"
  backup false
  rights :read, node['winrm']['Everyone_Group']
end

ruby_block 'read-winrm-thumbprint' do
  block do
    f = File.open("#{Chef::Config[:file_cache_path]}\\winrm.thumbprint", 'r')
    val = f.read.strip
    f.close
    node.default['winrm']['thumbprint'] = ((val.empty? || val.nil?) ? nil : val)
  end
  only_if { !File.zero?("#{Chef::Config[:file_cache_path]}\\winrm.thumbprint") && node['winrm']['thumbprint'].nil? && node['winrm']['https'] }
end

cookbook_file "#{Chef::Config[:file_cache_path]}\\selfssl.exe" do
  source 'selfssl.exe'
  only_if { node['winrm']['https'] && node['winrm']['thumbprint'].nil? }
end

execute 'create-certificate' do
  command "#{Chef::Config[:file_cache_path]}\\selfssl.exe /T /N:cn=#{node['fqdn']} /V:3650 /Q"
  only_if { node['winrm']['https'] && node['winrm']['thumbprint'].nil? }
  notifies :run, 'powershell[search-for-thumbprint]', :immediately
  notifies :create, 'ruby_block[read-winrm-thumbprint]', :immediately
  notifies :delete, 'file[cleanup-thumbprint]'
end

powershell 'winrm-quickconfig' do
  code 'winrm quickconfig -quiet'
  only_if { node['winrm']['http'] }
end

powershell 'winrm-create-https-listener' do
  code "winrm create 'winrm/config/Listener?Address=*+Transport=HTTPS' '@{Hostname=\"#{node['fqdn']}\"; CertificateThumbprint=\"#{node['winrm']['thumbprint']}\"}'"
  only_if { node['winrm']['https'] && !File.zero?("#{Chef::Config[:file_cache_path]}\\winrm.thumbprint") }
end

file 'cleanup-thumbprint' do
  path "#{Chef::Config[:file_cache_path]}\\winrm.thumbprint"
  action :delete
  backup false
end

powershell 'winrm-auth' do
  code "winrm set winrm/config/service/Auth '@{Basic=\"#{node['winrm']['BasicAuth']}\"}'"
end

powershell 'winrm-unencrypted' do
  code "winrm set winrm/config/service '@{AllowUnencrypted=\"#{node['winrm']['AllowUnencrypted']}\"}'"
end

powershell 'winrm-winrs' do
  code "winrm set winrm/config/winrs '@{MaxMemoryPerShellMB=\"#{node['winrm']['MaxMemoryPerShellMB']}\"}'"
end

powershell 'winrm-winrs-trustedhosts' do
  code "winrm set winrm/config/client '@{TrustedHosts=\"#{node['winrm']['TrustedHosts']}\"}'"
end

powershell 'winrm-http-listener' do
  code "winrm set winrm/config/Listener?Address=*+Transport=HTTP '@{Hostname=\"#{node['fqdn']}\"}'"
  only_if { node['winrm']['http'] }
end

powershell 'winrm-https-listener' do
  code "winrm set 'winrm/config/Listener?Address=*+Transport=HTTPS' '@{Hostname=\"#{node['fqdn']}\"; CertificateThumbprint=\"#{node['winrm']['thumbprint']}\"}'"
  only_if { node['winrm']['https'] && !node['winrm']['thumbprint'].nil? }
end

# unlock port in firewall
# this should leverage firewall_rule resource
# once COOK-689 is completed
firewall_rule_name = 'WINRM HTTP Static Port'

execute 'open-static-port-http' do
  command "netsh advfirewall firewall add rule name=\"#{firewall_rule_name}\" dir=in action=allow protocol=TCP localport=5985"
  returns [0, 1, 42] # *sigh* cmd.exe return codes are wonky
  not_if { Winrm::Helper.firewall_rule_enabled?(firewall_rule_name) }
  only_if { node['winrm']['http'] }
end

firewall_rule_name = 'WINRM HTTPS Static Port'

execute 'open-static-port-https' do
  command "netsh advfirewall firewall add rule name=\"#{firewall_rule_name}\" dir=in action=allow protocol=TCP localport=5986"
  returns [0, 1, 42] # *sigh* cmd.exe return codes are wonky
  not_if { Winrm::Helper.firewall_rule_enabled?(firewall_rule_name) }
  only_if { node['winrm']['https'] && !node['winrm']['thumbprint'].nil? }
end
