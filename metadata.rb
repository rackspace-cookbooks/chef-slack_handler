name "slack_handler"

maintainer       "Dan Ryan"
maintainer_email "dan.ryan@enstratius.com"
license          "Apache 2.0"
description      "Installs/Configures a Chef handler for reporting results to a Slack channel"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends "chef_handler"
