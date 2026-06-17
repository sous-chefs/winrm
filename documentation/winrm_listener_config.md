# winrm_listener_config

Configures WinRM listeners, selected service settings, and optional firewall rules on Windows.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Configures WinRM listeners and settings. |
| `:delete` | Removes configured listeners and optional firewall rules. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `hostname` | String | `node['fqdn']` | Hostname used for listener and certificate matching. |
| `trusted_hosts` | String | `'*'` | WinRM client trusted hosts value. |
| `max_shell_memory` | String, Integer | `1024` | Maximum memory per remote shell in MB. |
| `thumbprint` | String | `nil` | Certificate thumbprint for HTTPS listener. |
| `listen_http` | true, false | `true` | Whether to configure the HTTP listener. |
| `listen_https` | true, false | `true` | Whether to configure the HTTPS listener. |
| `allow_unencrypted` | true, false | `true` | Whether to allow unencrypted WinRM traffic. |
| `allow_basic_auth` | true, false | `true` | Whether to enable Basic authentication. |
| `generate_cert` | true, false | `true` | Whether to generate a self-signed certificate when none is found. |
| `add_firewall_rule` | true, false | `true` | Whether to manage WinRM firewall rules. |

## Examples

### Basic usage

```ruby
winrm_listener_config 'default'
```

### Harden listener settings

```ruby
winrm_listener_config 'default' do
  listen_http false
  allow_unencrypted false
  allow_basic_auth false
end
```

### Use an existing certificate

```ruby
winrm_listener_config 'default' do
  thumbprint '0123456789ABCDEF0123456789ABCDEF01234567'
end
```
