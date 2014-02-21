WinRM Cookbook
================
Installs and configures WinRM on a Windows System 

[![Build Status](https://travis-ci.org/Webtrends/winrm.png?branch=master)](https://travis-ci.org/Webtrends/winrm) [![Code Climate](https://codeclimate.com/github/Webtrends/winrm.png)](https://codeclimate.com/github/Webtrends/winrm)

Requirements
------------
### Platform
* Windows 7 Enterprise
* Windows 2008
* Windows 2008 R2

**Notes**: This cookbook has been tested on the listed platforms. It may work on other platforms with or without modification.


### Cookbooks
* Windows
* Powershell


Attributes
----------
### default
* `node['winrm']['thumbprint']` - The SSL thumbprint WinRM uses for incomming connections, will be generated if not found (only used when SSL is enabled)
* `node['winrm']['https']` - Enable SSL for WinRM, default 'true'
* `node['winrm']['http']` - Enable HTTP for WinRM, defautl 'true'
* `node['winrm']['BasicAuth']` - Support basic authentication, default 'true'
* `node['winrm']['MaxMemoryPerShellMB']` - Max memory per WinRM shell allowed in MB, default '1024'
* `node['winrm']['AllowUnencrypted']` - Allow unencrypted data transfers, default 'true'
* `node['winrm']['TrustedHosts']` - Hosts that are allowed to connect via WinRM, default '*'


Recipes
-------
### default
Installs and configures WinRM on the windows system.  Ensures firewall rules allow traffic to WinRM. 

The recipe does the following:

1. Search for thumbprint for the FQDN of the node, if found use it.  Otherwise create a new self signed SSL certificate if SSL is enabled.
2. Install WinRM via quick configure
3. Configure listeners, HTTP and/or HTTPS 
4. Create SSH keys from data bag
5. Create firewall rules if needed


License & Authors
-----------------
- Author:: Peter Crossley <peter.crossley@webtrends.com>

```text
Copyright 2014, Webtrends Inc.

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
