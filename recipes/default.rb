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
if platform_family?('windows')

  powershell_script 'search-for-thumbprint' do
    cwd Chef::Config[:file_cache_path]
    code "Get-childItem cert:\\LocalMachine\\Root\\ | Select-String -pattern #{node['winrm']['hostname']} | Select-Object -first 1 -ExpandProperty line | % { $_.SubString($_.IndexOf('[Thumbprint]')+ '[Thumbprint]'.Length).Trim()} | Out-File -Encoding \"ASCII\" winrm.thumbprint"
    only_if { node['winrm']['thumbprint'].nil? && node['winrm']['https'] }
    # notifies :create, 'file[fix-perms-thumbprint]', :immediately
  end

  # file 'fix-perms-thumbprint' do
  # action :nothing
  # path "#{Chef::Config[:file_cache_path]}\\winrm.thumbprint"
  # backup false
  # rights :read, node['winrm']['Everyone_Group']
  # end

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
    command "#{Chef::Config[:file_cache_path]}\\selfssl.exe /T /N:cn=#{node['winrm']['hostname']} /V:3650 /Q"
    only_if { node['winrm']['https'] && node['winrm']['thumbprint'].nil? }
    notifies :run, 'powershell_script[search-for-thumbprint]', :immediately
    notifies :create, 'ruby_block[read-winrm-thumbprint]', :immediately
    notifies :delete, 'file[cleanup-thumbprint]', :immediately
  end

  file 'cleanup-thumbprint' do
    path "#{Chef::Config[:file_cache_path]}\\winrm.thumbprint"
    action :delete
    backup false
  end

  # Configure winrm
  # use attributes to add other configuration
  powershell_script 'enable winrm' do
    code <<-EOH
      winrm quickconfig -q
    EOH
  end

  # check if https listener already exists
  winrm_cmd = 'powershell.exe winrm enumerate winrm/config/listener'
  shell_out = Mixlib::ShellOut.new(winrm_cmd)
  shell_out.run_command

  # Create HTTPS listener
  if !shell_out.stdout.include?('Transport = HTTPS') && node['winrm']['https']
    if node['winrm']['thumbprint'].nil? || node['winrm']['thumbprint'].empty?
      Chef::Log.error('Please specify thumbprint in default attributes for enabling https transport.')
    else
      powershell_script 'winrm-create-https-listener' do
        code "winrm create 'winrm/config/Listener?Address=*+Transport=HTTPS' '@{Hostname=\"#{node['winrm']['hostname']}\"; CertificateThumbprint=\"#{node['winrm']['thumbprint']}\"}'"
      end
    end
  else
    Chef::Log.warn('WinRM HTTPS listener is already configured. Please delete the existing https listener first to configure new one.')
  end

  # Create HTTP listener
  if !shell_out.stdout.include?('Transport = HTTP') && node['winrm']['http']
    powershell_script 'winrm-create-https-listener' do
      code "winrm set winrm/config/Listener?Address=*+Transport=HTTP '@{Hostname=\"#{node['winrm']['hostname']}\"}'"
    end
  else
    Chef::Log.warn('WinRM HTTP listener is already configured. Please delete the existing https listener first to configure new one.')
  end

  # Configure extended options
  powershell_script 'winrm-auth' do
    code "winrm set winrm/config/service/Auth '@{Basic=\"#{node['winrm']['BasicAuth']}\"}'"
  end

  powershell_script 'winrm-unencrypted' do
    code "winrm set winrm/config/service '@{AllowUnencrypted=\"#{node['winrm']['AllowUnencrypted']}\"}'"
  end

  powershell_script 'winrm-winrs' do
    code "winrm set winrm/config/winrs '@{MaxMemoryPerShellMB=\"#{node['winrm']['MaxMemoryPerShellMB']}\"}'"
  end

  powershell_script 'winrm-winrs-trustedhosts' do
    code "winrm set winrm/config/client '@{TrustedHosts=\"#{node['winrm']['TrustedHosts']}\"}'"
  end

  powershell_script 'winrm-http-listener' do
    code "winrm set winrm/config/Listener?Address=*+Transport=HTTP '@{Hostname=\"#{node['fqdn']}\"}'"
    only_if { node['winrm']['http'] }
  end

  # Allow port in firewall
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
else
  Chef::Log.warn('WinRM can only be enabled on the Windows platform.')
end
