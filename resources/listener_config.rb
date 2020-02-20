#
# Resource:: winrm_listener_config
#
# Author:: Peter Crossley
# Author:: Tim Smith
#
# Copyright:: 2012, Webtrends Inc.
# Copyright:: 2019, Chef Software, Inc.
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

provides :winrm_listener_config
provides :winrm # legacy name

property :hostname, String, default: lazy { node['fqdn'] }
property :trusted_hosts, String, default: '*'
property :max_shell_memory, [String, Integer], default: 1024
property :thumbprint, String
property :listen_http, [true, false], default: true
property :listen_https, [true, false], default: true
property :allow_unencrypted, [true, false], default: true
property :allow_basic_auth, [true, false], default: true
property :generate_cert, [true, false], default: true
property :add_firewall_rule, [true, false], default: true

# support the legacy names that were just the PowerShell names
alias :Hostname :hostname
alias :TrustedHosts :trusted_hosts
alias :MaxMemoryPerShellMB :max_shell_memory
alias :Thumbprint :thumbprint
alias :HTTP :listen_http
alias :HTTPS :listen_https
alias :AllowUnencrypted :allow_unencrypted
alias :BasicAuth :allow_basic_auth
alias :GenerateCert :generate_cert

action :create do
  # If no certificate found and generateCert is true try to generate a self signed cert
  if new_resource.generate_cert && new_resource.listen_https && new_resource.thumbprint.nil? && load_thumbprint.empty?
    Chef::Log.warn('Inside Create Cert')
    cookbook_file "#{Chef::Config[:file_cache_path]}\\selfssl.exe" do
      source 'selfssl.exe'
    end

    execute 'create-certificate' do
      command "#{Chef::Config[:file_cache_path]}\\selfssl.exe /T /N:cn=#{new_resource.hostname} /V:3650 /Q"
    end
  end

  thumbprint = new_resource.thumbprint.nil? ? load_thumbprint : new_resource.thumbprint

  # Configure winrm
  execute 'Enable WinRM' do
    command 'winrm quickconfig -q'
  end

  # check if https listener already exists
  winrm_cmd = 'winrm enumerate winrm/config/listener'
  winrm_out = powershell_out!(winrm_cmd)

  # Create HTTPS listener
  if !winrm_out.stdout.include?('Transport = HTTPS') && new_resource.listen_https
    if thumbprint.nil? || thumbprint.empty?
      Chef::Log.error('Please specify thumbprint or set GenerateCert to true for enabling https transport.')
    else
      powershell_script 'winrm-create-https-listener' do
        code "winrm create 'winrm/config/Listener?Address=*+Transport=HTTPS' '@{Hostname=\"#{new_resource.hostname}\"; CertificateThumbprint=\"#{thumbprint}\"}'"
      end
    end
  else
    Chef::Log.warn('WinRM HTTPS listener is already configured. Please delete the existing https listener first to configure new one.')
  end

  # Create HTTP listener
  if !winrm_out.stdout.include?('Transport = HTTP') && new_resource.listen_http
    powershell_script 'winrm-create-https-listener' do
      code "winrm set winrm/config/Listener?Address=*+Transport=HTTP '@{Hostname=\"#{new_resource.hostname}\"}'"
    end
  else
    Chef::Log.warn('WinRM HTTP listener is already configured. Please delete the existing https listener first to configure new one.')
  end

  # Configure extended options
  powershell_script 'winrm-auth' do
    code "winrm set winrm/config/service/Auth '@{Basic=\"#{new_resource.allow_basic_auth}\"}'"
  end

  powershell_script 'winrm-unencrypted' do
    code "winrm set winrm/config/service '@{AllowUnencrypted=\"#{new_resource.allow_unencrypted}\"}'"
  end

  powershell_script 'winrm-winrs' do
    code "winrm set winrm/config/winrs '@{MaxMemoryPerShellMB=\"#{new_resource.max_shell_memory}\"}'"
  end

  powershell_script 'winrm-winrs-trustedhosts' do
    code "winrm set winrm/config/client '@{TrustedHosts=\"#{new_resource.trusted_hosts}\"}'"
  end

  # Allow ports in firewall if configured
  if new_resource.add_firewall_rule
    windows_firewall_rule 'WINRM HTTP Static Port' do
      local_port '5985'
      protocol 'TCP'
      firewall_action :allow
    end

    windows_firewall_rule 'WINRM HTTPS Static Port' do
      local_port '5986'
      protocol 'TCP'
      firewall_action :allow
      only_if { new_resource.listen_http }
    end
  end
end

action_class do
  def load_thumbprint
    cert_cmd = "Get-ChildItem Cert:\\LocalMachine\\My\\ -Recurse | where-Object {$_.Subject -match \"#{new_resource.hostname}\" } | Select-Object -First 1 | % { $_.Thumbprint }"
    cert_out = powershell_out!(cert_cmd)
    cert_out.stdout.strip
  end
end
