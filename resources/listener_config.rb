# frozen_string_literal: true

provides :winrm_listener_config
provides :winrm # legacy name
unified_mode true

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
  powershell_script 'winrm-enable' do
    code 'winrm quickconfig -q'
    not_if powershell_true("(Get-Service WinRM).Status -eq 'Running'")
  end

  powershell_script 'winrm-create-self-signed-certificate' do
    code <<~POWERSHELL
      New-SelfSignedCertificate `
        -DnsName '#{ps_single_quote(new_resource.hostname)}' `
        -CertStoreLocation 'Cert:\\LocalMachine\\My' `
        -NotAfter (Get-Date).AddYears(10) | Out-Null
    POWERSHELL
    only_if { new_resource.generate_cert && new_resource.listen_https && new_resource.thumbprint.nil? }
    not_if certificate_guard
  end

  powershell_script 'winrm-create-https-listener' do
    code <<~POWERSHELL
      $thumbprint = #{thumbprint_expression}
      if ([string]::IsNullOrWhiteSpace($thumbprint)) {
        throw 'Specify thumbprint or set generate_cert true for HTTPS WinRM.'
      }
      winrm create 'winrm/config/Listener?Address=*+Transport=HTTPS' "@{Hostname=\\"#{new_resource.hostname}\\"; CertificateThumbprint=\\"$thumbprint\\"}"
    POWERSHELL
    only_if { new_resource.listen_https }
    not_if listener_guard('HTTPS')
  end

  powershell_script 'winrm-create-http-listener' do
    code "winrm set winrm/config/Listener?Address=*+Transport=HTTP '@{Hostname=\"#{new_resource.hostname}\"}'"
    only_if { new_resource.listen_http }
    not_if listener_guard('HTTP')
  end

  powershell_script 'winrm-auth' do
    code "winrm set winrm/config/service/Auth '@{Basic=\"#{winrm_bool(new_resource.allow_basic_auth)}\"}'"
    not_if winrm_setting_guard('winrm get winrm/config/service/Auth', 'Basic', winrm_bool(new_resource.allow_basic_auth))
  end

  powershell_script 'winrm-unencrypted' do
    code "winrm set winrm/config/service '@{AllowUnencrypted=\"#{winrm_bool(new_resource.allow_unencrypted)}\"}'"
    not_if winrm_setting_guard('winrm get winrm/config/service', 'AllowUnencrypted', winrm_bool(new_resource.allow_unencrypted))
  end

  powershell_script 'winrm-winrs' do
    code "winrm set winrm/config/winrs '@{MaxMemoryPerShellMB=\"#{new_resource.max_shell_memory}\"}'"
    not_if winrm_setting_guard('winrm get winrm/config/winrs', 'MaxMemoryPerShellMB', new_resource.max_shell_memory)
  end

  powershell_script 'winrm-winrs-trustedhosts' do
    code "winrm set winrm/config/client '@{TrustedHosts=\"#{new_resource.trusted_hosts}\"}'"
    not_if winrm_setting_guard('winrm get winrm/config/client', 'TrustedHosts', new_resource.trusted_hosts)
  end

  if new_resource.add_firewall_rule
    windows_firewall_rule 'WINRM HTTP Static Port' do
      local_port '5985'
      protocol 'TCP'
      firewall_action :allow
      only_if { new_resource.listen_http }
    end

    windows_firewall_rule 'WINRM HTTPS Static Port' do
      local_port '5986'
      protocol 'TCP'
      firewall_action :allow
      only_if { new_resource.listen_https }
    end
  end
end

action :delete do
  powershell_script 'winrm-delete-https-listener' do
    code "winrm delete 'winrm/config/Listener?Address=*+Transport=HTTPS'"
    only_if { new_resource.listen_https }
    only_if listener_guard('HTTPS')
  end

  powershell_script 'winrm-delete-http-listener' do
    code "winrm delete 'winrm/config/Listener?Address=*+Transport=HTTP'"
    only_if { new_resource.listen_http }
    only_if listener_guard('HTTP')
  end

  if new_resource.add_firewall_rule
    windows_firewall_rule 'WINRM HTTP Static Port' do
      action :delete
      only_if { new_resource.listen_http }
    end

    windows_firewall_rule 'WINRM HTTPS Static Port' do
      action :delete
      only_if { new_resource.listen_https }
    end
  end
end

action_class do
  def certificate_guard
    powershell_true("(-not [string]::IsNullOrWhiteSpace((#{certificate_lookup_expression})))")
  end

  def certificate_lookup_expression
    "Get-ChildItem Cert:\\LocalMachine\\My\\ -Recurse | Where-Object { $_.Subject -match '#{ps_single_quote(new_resource.hostname)}' } | Select-Object -First 1 | ForEach-Object { $_.Thumbprint }"
  end

  def listener_guard(protocol)
    powershell_true("((& winrm enumerate winrm/config/listener) -match '(?m)^\\s*Transport\\s*=\\s*#{protocol}\\s*$')")
  end

  def powershell_true(expression)
    "if (#{expression}) { exit 0 } else { exit 1 }"
  end

  def ps_single_quote(value)
    value.to_s.gsub("'", "''")
  end

  def thumbprint_expression
    if new_resource.thumbprint
      "'#{ps_single_quote(new_resource.thumbprint)}'"
    else
      certificate_lookup_expression
    end
  end

  def winrm_bool(value)
    value ? 'true' : 'false'
  end

  def winrm_setting_guard(command, setting, expected)
    expected_pattern = Regexp.escape(expected.to_s)
    powershell_true("((& #{command}) -match '(?im)^\\s*#{Regexp.escape(setting)}\\s*=\\s*#{expected_pattern}\\s*$')")
  end
end
