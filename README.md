# WinRM Cookbook

[![Build Status](https://travis-ci.org/sous-chefs/winrm.svg?branch=master)](https://travis-ci.org/sous-chefs/winrm) [![Cookbook Version](https://img.shields.io/cookbook/v/winrm.svg)](https://supermarket.chef.io/cookbooks/winrm)

Installs and configures WinRM on a Windows System 

## Requirements

### Platforms

- Windows 2008 R2
- Windows 2012 R2

If you would like support for your preferred platform. Please think about creating a Vagrant Box and adding test platforms

### Chef

- Chef 12.7+

## Known Limitations

- Does not install powershell, must be already installed.

## Recipes

### default

Installs and configures WinRM on the windows system.  Ensures firewall rules allow traffic to WinRM. 

The recipe does the following:

1. Search for thumbprint for the FQDN of the node, if found use it.  Otherwise create a new self signed SSL certificate if SSL is enabled.
2. Install WinRM via quick configure
3. Configure listeners, HTTP and/or HTTPS 
4. Configure additional options
5. Create firewall rules

## Resources

### Server

```ruby
winrm 'default' do
  Hostname # Used for creating the listeners and finding the certificate thumbprint or creating a new one, default node['fqdn']
  TrustedHosts # Trusted hosts to allow connections from, default '*'
  MaxMemoryPerShellMB # Max memory allowed for each remote shell, default 1024
  Thumbprint # Specify a certificate thumbprint to use, if `nil` will looks for certificate matching hostname, default nil
  HTTP # Enable HTTP listener, default true
  HTTPS # Enable HTTPS listener, default true
  AllowUnencrypted # Wether to allow unencrypted WinRM connections, default true
  BasicAuth # Enable Basic Authentication, default true
  GenerateCert # Wether to generate a cert if none is found, default true
end
```

## Usage

The `winrm::default` recipe includes the winrm resource using defaults

Create a cookbook with the `winrm` resource as if you were using any other Chef resource.

For examples see the `test/fixtures/cookbooks/test` directory.

## License

Copyright 2014-2015, Webtrends Inc.

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[user resource]: https://docs.chef.io/resource_user.html