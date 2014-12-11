#
# Author:: Dell Cloud Manager OSS
# Copyright:: Dell, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "chef_handler"

handler_file = ''
handler_source = ''

# if webhook attribute set, use webhook handler, otherwise use slackr gem handler
if node['chef_client']['handler']['slack']['webhooks'].nil?
  # use slackr to post message. slackr gem and apikey required
  chef_gem "slackr"
  handler_file = "#{node['chef_handler']['handler_path']}/slack_handler.rb"
  handler_source = "slack_handler.rb"
else
  handler_file = "#{node['chef_handler']['handler_path']}/slack_handler_webhook.rb"
  handler_source = "slack_handler_webhook.rb"
end

cookbook_file handler_file do
  source handler_source
  mode "0600"
  action :nothing
# end
end.run_action(:create)

chef_handler "Chef::Handler::Slack" do
  source handler_file
  arguments [
              node['chef_client']['handler']['slack']
            ]
  action :nothing
end.run_action(:enable)
