default['winrm']['https'] = true
default['winrm']['thumbprint'] = nil # mandatory for https transport
default['winrm']['http'] = true
default['winrm']['BasicAuth'] = true
default['winrm']['MaxMemoryPerShellMB'] = 1024
default['winrm']['AllowUnencrypted'] = true
default['winrm']['TrustedHosts'] = '*'
default['winrm']['Everyone_Group'] = 'Everyone'
default['winrm']['hostname'] = node['fqdn']
