# WinRM Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/winrm.svg)](https://supermarket.chef.io/cookbooks/winrm)
[![Build Status](https://img.shields.io/circleci/project/github/sous-chefs/winrm/master.svg)](https://circleci.com/gh/sous-chefs/winrm)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

Installs and configures WinRM on a Windows System

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

### Platforms

- Windows 2012 / 2012 R2
- Windows 2016
- Windows 2019
- Windows 2022

### Chef

- Chef 15.4+

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

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)
