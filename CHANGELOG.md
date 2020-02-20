# Changelog

## Unreleased

- refer to the correct certificate store for machine certs
- return the certificate thumbprint as an object attribute, not a substring search
- Migrate to actions

## 3.0.0 (2019-02-02)

- This cookbook now requires Chef 13 or later as Chef 12 has been end of life for nearly a year
- Rename the `winrm` resource to `winrm_listener_config` with backwards compatibility for the old name
- Renamed the resource properties to better align with other Chef resources while providing full compatibility with the previous names

## 2.0.0 (2017-10-19)

- BREAKING CHANGE, attributes no longer exist
- Convert to custom resource
- Update to work with newer chef versions

## 1.0.2

- Added configurable Everyone group attribute

## 1.0.1 (10-16-2015)

- Added Kitchen CI config
- Added rubocop config
- Added Berksfile
- Added gitignore and chefignore filex
- Moved Gemfile and add standard development dependencies
- Fixed the license in the metadata to be Apache 2.0
- Added modern Ruby releases to Travis and add rubocop and chefspec testing
- Added retina badges to the readme and added the cookbook version badge

## 1.0.0 (02-14-2014)

- Initial release of the WinRM cookbook
- Adding support for Travis-CI and foodcritic
