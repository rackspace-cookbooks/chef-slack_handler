name 'slack_handler'

maintainer       'Rackspace'
maintainer_email 'rackspace-cookbooks@rackspace.com'
license          'Apache-2.0'
description      'Installs/Configures a Chef handler for reporting results to a Slack channel.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.9.2'

depends 'chef_handler', '~> 2.1.2'

supports 'ubuntu'
supports 'centos'
supports 'fedora'
supports 'redhat'
supports 'debian'

source_url 'https://github.com/rackspace-cookbooks/chef-slack_handler' if respond_to?(:source_url)
issues_url 'https://github.com/rackspace-cookbooks/chef-slack_handler/issues' if respond_to?(:issues_url)
chef_version '>= 12.1' if respond_to?(:chef_version)
