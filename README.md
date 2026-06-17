# WinRM Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/winrm.svg)](https://supermarket.chef.io/cookbooks/winrm)
[![CI State](https://github.com/sous-chefs/winrm/workflows/ci/badge.svg)](https://github.com/sous-chefs/winrm/actions?query=workflow%3Aci)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

Provides custom resources for configuring WinRM listeners on Windows hosts.

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook
maintainers working together to maintain important cookbooks. If you would like to know more,
visit [sous-chefs.org](https://sous-chefs.org/) or chat with us on the Chef Community Slack in
[#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

### Platforms

* Windows Server 2016
* Windows Server 2019
* Windows Server 2022
* Windows Server 2025

### Chef

* Chef Infra Client 15.3+

### Additional Requirements

* PowerShell must be available.

## Resources

* [winrm_listener_config](documentation/winrm_listener_config.md)

## Usage

Configure default HTTP and HTTPS listeners:

```ruby
winrm_listener_config 'default'
```

Harden listener settings:

```ruby
winrm_listener_config 'default' do
  listen_http false
  allow_unencrypted false
  allow_basic_auth false
end
```

## Migration

This cookbook no longer ships public recipes. See [migration.md](migration.md) for migration
guidance from `recipe[winrm::default]` to `winrm_listener_config`.

## Contributors

This project exists thanks to all the people who contribute.

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
