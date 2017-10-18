#
# Cookbook Name:: winrm
# Resource:: winrm
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
resource_name :winrm
default_action :create

property :Hostname, String, default: node['fqdn']
property :EveryoneGroup, String, default: 'Everyone'
property :TrustedHosts, String, default: '*'
property :MaxMemoryPerShellMB, [String, Integer], default: 1024
property :Thumbprint, [String, nil], default: nil
property :HTTP, [true, false], default: true
property :HTTPS, [true, false], default: true
property :AllowUnencrypted, [true, false], default: true
property :BasicAuth, [true, false], default: true
property :GenerateCert, [true, false], default: true

action :create do
  Chef::Log.warn('load_thumbprint1')
  Chef::Log.warn(load_thumbprint)

  # If no certificate found and generateCert is true try to generate a self signed cert
  if new_resource.HTTPS && thumbprint.nil? && load_thumbprint.nil?
    cookbook_file "#{Chef::Config[:file_cache_path]}\\selfssl.exe" do
      source 'selfssl.exe'
    end

    execute 'create-certificate' do
      command "#{Chef::Config[:file_cache_path]}\\selfssl.exe /T /N:cn=#{new_resource.Hostname} /V:3650 /Q"
      notifies :run, 'powershell_script[search-for-thumbprint]', :immediately
      notifies :create, 'ruby_block[read-winrm-thumbprint]', :immediately
      notifies :delete, 'file[cleanup-thumbprint]', :immediately
    end
  end

  Chef::Log.warn('new_resource.Thumbprint')
  Chef::Log.warn(new_resource.Thumbprint)
  Chef::Log.warn('load_thumbprint2')
  Chef::Log.warn(load_thumbprint)

  thumbprint = new_resource.Thumbprint.nil? ? load_thumbprint : new_resource.Thumbprint

  # powershell_script 'search-for-thumbprint' do
  # cwd Chef::Config[:file_cache_path]
  # code "Get-childItem cert:\\LocalMachine\\Root\\ | Select-String -pattern #{new_resource.Hostname} | Select-Object -first 1 -ExpandProperty line | % { $_.SubString($_.IndexOf('[Thumbprint]')+ '[Thumbprint]'.Length).Trim()} | Out-File -Encoding \"ASCII\" winrm.thumbprint"
  # only_if { new_resource.Thumbprint.nil? && new_resource.HTTPS }
  # end

  # ruby_block 'read-winrm-thumbprint' do
  # block do
  # f = File.open("#{Chef::Config[:file_cache_path]}\\winrm.thumbprint", 'r')
  # val = f.read.strip
  # f.close
  # node.default['winrm']['thumbprint'] = ((val.empty? || val.nil?) ? nil : val)
  # end
  # only_if { !File.zero?("#{Chef::Config[:file_cache_path]}\\winrm.thumbprint") && new_resource.Thumbprint.nil? && new_resource.HTTPS }
  # end

  # file 'cleanup-thumbprint' do
  # path "#{Chef::Config[:file_cache_path]}\\winrm.thumbprint"
  # action :delete
  # backup false
  # end

  # Configure winrm
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
  if !shell_out.stdout.include?('Transport = HTTPS') && new_resource.HTTPS
    if thumbprint.nil? || thumbprint.empty?
      Chef::Log.error('Please specify thumbprint or set GenerateCert to true for enabling https transport.')
    else
      powershell_script 'winrm-create-https-listener' do
        code "winrm create 'winrm/config/Listener?Address=*+Transport=HTTPS' '@{Hostname=\"#{new_resource.Hostname}\"; CertificateThumbprint=\"#{thumbprint}\"}'"
      end
    end
  else
    Chef::Log.warn('WinRM HTTPS listener is already configured. Please delete the existing https listener first to configure new one.')
  end

  # Create HTTP listener
  if !shell_out.stdout.include?('Transport = HTTP') && new_resource.HTTP
    powershell_script 'winrm-create-https-listener' do
      code "winrm set winrm/config/Listener?Address=*+Transport=HTTP '@{Hostname=\"#{new_resource.Hostname}\"}'"
    end
  else
    Chef::Log.warn('WinRM HTTP listener is already configured. Please delete the existing https listener first to configure new one.')
  end

  # Configure extended options
  powershell_script 'winrm-auth' do
    code "winrm set winrm/config/service/Auth '@{Basic=\"#{new_resource.BasicAuth}\"}'"
  end

  powershell_script 'winrm-unencrypted' do
    code "winrm set winrm/config/service '@{AllowUnencrypted=\"#{new_resource.AllowUnencrypted}\"}'"
  end

  powershell_script 'winrm-winrs' do
    code "winrm set winrm/config/winrs '@{MaxMemoryPerShellMB=\"#{new_resource.MaxMemoryPerShellMB}\"}'"
  end

  powershell_script 'winrm-winrs-trustedhosts' do
    code "winrm set winrm/config/client '@{TrustedHosts=\"#{new_resource.TrustedHosts}\"}'"
  end

  # Allow port in firewall
  firewall_rule_name = 'WINRM HTTP Static Port'

  execute 'open-static-port-http' do
    command "netsh advfirewall firewall add rule name=\"#{firewall_rule_name}\" dir=in action=allow protocol=TCP localport=5985"
    returns [0, 1, 42] # *sigh* cmd.exe return codes are wonky
    not_if { Winrm::Helper.firewall_rule_enabled?(firewall_rule_name) }
    only_if { new_resource.HTTP }
  end

  firewall_rule_name = 'WINRM HTTPS Static Port'

  execute 'open-static-port-https' do
    command "netsh advfirewall firewall add rule name=\"#{firewall_rule_name}\" dir=in action=allow protocol=TCP localport=5986"
    returns [0, 1, 42] # *sigh* cmd.exe return codes are wonky
    not_if { Winrm::Helper.firewall_rule_enabled?(firewall_rule_name) }
    only_if { new_resource.HTTPS && !thumbprint.nil? }
  end
end

action_class do
  def load_thumbprint
    cert_cmd = "powershell.exe -Command \" & {Get-childItem cert:\\LocalMachine\\Root\\ | Select-String -pattern #{new_resource.Hostname} | Select-Object -first 1 -ExpandProperty line | % { $_.SubString($_.IndexOf('[Thumbprint]')+ '[Thumbprint]'.Length).Trim()}}\""
    cert_shell_out = Mixlib::ShellOut.new(cert_cmd)
    cert_shell_out.run_command
    shell_out.stdout.strip
  end

  def whyrun_supported?
    true
  end
end
