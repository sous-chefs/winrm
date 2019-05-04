# WinRM Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/winrm.svg)](https://supermarket.chef.io/cookbooks/winrm)

Installs and configures WinRM on a Windows System

## Requirements

### Platforms

- Windows 2008 R2
- Windows 2012 / 2012 R2
- Windows 2016

### Chef

- Chef 13.0+

## Additional Requirements

- PowerShell must already be installed

## Resources

### winrm_listener_config

Configure winrm listeners on a host. Previously this resource was named `winrm` and that legacy name will continue to function.

#### Actions

- `:create` - configure a listener

#### Properties

- `hostname` - Used for creating the listeners and finding the certificate thumbprint or creating a new one, default node['fqdn']
- `trusted_hosts` - Trusted hosts to allow connections from, default '*'
- `max_shell_memory` - Max memory allowed for each remote shell, default 1024
- `thumbprint` - Specify a certificate thumbprint to use, if `nil` will looks for certificate matching hostname, default nil
- `listen_http` - Enable HTTP listener, default true
- `listen_https` - Enable HTTPS listener, default true
- `allow_unencrypted` - Wether to allow unencrypted WinRM connections, default true
- `allow_basic_auth` - Enable Basic Authentication, default true
- `generate_cert` - Whether to generate a cert if none is found, default true
- `add_firewall_rule` - Whether to create a firewall rule which allows WinRM access, default true

#### Examples

```ruby
winrm_listener_config 'default' do
  listen_http false
  allow_unencrypted false
end
```

## Contributors

This project exists thanks to all the people who contribute.
<img src="https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false" /></a>


### Backers

Thank you to all our backers! 🙏 [[Become a backer](https://opencollective.com/sous-chefs#backer)]
<a href="https://opencollective.com/sous-chefs#backers" target="_blank"><img src="https://opencollective.com/sous-chefs/backers.svg?width=890"></a>

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website. [[Become a sponsor](https://opencollective.com/sous-chefs#sponsor)]
<a href="https://opencollective.com/sous-chefs/sponsor/0/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/0/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/1/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/1/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/2/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/2/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/3/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/3/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/4/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/4/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/5/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/5/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/6/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/6/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/7/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/7/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/8/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/8/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/9/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/9/avatar.svg"></a>

## License

Copyright 2014-2015, Webtrends Inc.
Copyright 2019, Chef Software, Inc.

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
