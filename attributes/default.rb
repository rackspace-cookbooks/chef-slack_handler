#
# Copyright ???
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Attributes for Slack intergration Using slackr gem. Requires API key
## required attributes
default['chef_client']['handler']['slack']['team']       = nil
default['chef_client']['handler']['slack']['api_key']    = nil
## Optional attributes
default['chef_client']['handler']['slack']['channel']    = nil




# Attributes for Slack intergration using webhook. No API key required. 
# Multiple webhooks supported. Report detail and fail_only set per webhook.
default_unless['chef_client']['handler']['slack']['webhooks']['name'] = []
# use like this
#default['chef_client']['handler']['slack']['webhooks']['name'].push('webhook1')
#default['chef_client']['handler']['slack']['webhooks']['webhook1']['url'] = nil
#default['chef_client']['handler']['slack']['webhooks']['webhook1']['fail_only'] = nil
#default['chef_client']['handler']['slack']['webhooks']['webhook1']['detail_level'] = nil

# shared attributes
default['chef_client']['handler']['slack']['username']   = node.name
default['chef_client']['handler']['slack']['icon_url']   = nil
# OR
default['chef_client']['handler']['slack']['icon_emoji'] = nil
# Valid options here are basic, elapsed, resources
default['chef_client']['handler']['slack']['detail_level'] = nil
# Only report failures
default['chef_client']['handler']['slack']['fail_only'] = nil