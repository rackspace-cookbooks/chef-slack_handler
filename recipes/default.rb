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

chef_gem "slackr"

cookbook_file "#{node['chef_handler']['handler_path']}/slack_handler.rb" do
  source "slack_handler.rb"
  mode "0600"
  action :nothing
# end
end.run_action(:create)

chef_handler "Chef::Handler::Slack" do
  source "#{node['chef_handler']['handler_path']}/slack_handler.rb"
  arguments [
              node['chef_client']['handler']['slack']
            ]
  action :nothing
end.run_action(:enable)
