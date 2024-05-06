# Changelog

## Unreleased

- Update ci.yml to use sous-chef reusable workflow
- Add unified_mode flag
- Remove EOL'd OS version
- Remove deprecated windows_firewall cookbook dependency
- Update minimum Chef version to 15.4
- Add minimal unit tests
- Update spec test to use a supported OS version
- Update kitchen.yml and kitchen.appveyor.yml to remove EOL'd OS version
- Add kitchen-azure.yml with all currently supported OS versions.
- Update README with minimum Chf versions and supported windows versions
- Remove Appveyor.yml and kitchen.appveyor.yml
- Remove kitchen-azure.yml

## 3.0.5 - *2024-05-06*

## 3.0.4 - *2023-11-01*

- resolved cookstyle error: metadata.rb:13:1 refactor: `Chef/Modernize/DependsOnWindowsFirewallCookbook`
- resolved cookstyle error: resources/listener_config.rb:1:1 refactor: `Chef/Deprecations/ResourceWithoutUnifiedTrue`
- Update testing

## 3.0.3 - *2021-08-31*

- Standardise files with files in sous-chefs/repo-management

## 3.0.2 - *2021-06-01*

- resolved cookstyle error: test/smoke/default/default_test.rb:1:1 convention: `Style/Encoding`

## 3.0.1

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
