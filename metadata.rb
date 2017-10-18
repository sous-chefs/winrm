name             'winrm'
maintainer       'Webtrends, Inc.'
maintainer_email 'Peter Crossley <peter.crossley@webtrends.com>'
license          'Apache-2.0'
description      'Installs and configures WinRM'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.2'
supports         'windows'
depends          'windows'
depends          'powershell'
source_url       'https://github.com/webtrends/winrm' if respond_to?(:source_url)
issues_url       'https://github.com/webtrends/winrm/issues' if respond_to?(:issues_url)
chef_version     '>= 12.7' if respond_to?(:chef_version)
