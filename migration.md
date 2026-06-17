# WinRM migration guide

This release removes the legacy recipe API. Use the `winrm_listener_config` custom resource
directly from a wrapper cookbook.

## Removed

* `recipe[winrm::default]`
* Berkshelf dependency resolution
* The bundled `selfssl.exe` helper

## Before

```ruby
run_list 'recipe[winrm::default]'
```

## After

```ruby
winrm_listener_config 'default' do
  listen_http false
  allow_unencrypted false
end
```

## Certificate generation

When `listen_https true`, `generate_cert true`, and no matching certificate thumbprint is found,
the resource now generates a self-signed certificate with PowerShell's
`New-SelfSignedCertificate` cmdlet.

## Resource alias

The `winrm` resource alias remains available:

```ruby
winrm 'default' do
  listen_http false
end
```
