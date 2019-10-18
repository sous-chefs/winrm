name             'winrm'
maintainer       'Sous Chefs'
maintainer_email 'help@sous-chefs.org'
license          'Apache-2.0'
description      'Installs and configures WinRM'

version          '3.0.0'
supports         'windows'
source_url       'https://github.com/sous-chefs/winrm'
issues_url       'https://github.com/sous-chefs/winrm/issues'
chef_version     '>= 13.0'
depends          'windows_firewall', '>= 5.0' # >= chef 14.7
