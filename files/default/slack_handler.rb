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

require "chef"
require "chef/handler"

begin
  require "slackr"
rescue LoadError
  Chef::Log.debug("Chef slack_handler requires `slackr` gem")
end

require "timeout"

class Chef::Handler::Slack < Chef::Handler
  attr_reader :team, :api_key, :config, :timeout, :fail_only, :detail_level

  def initialize(config = {})
    @config  = config.dup
    @team    = @config.delete(:team)
    @api_key = @config.delete(:api_key)
    @timeout = @config.delete(:timeout) || 15
    @fail_only = @config.delete(:fail_only) || false
    @detail_level = @config.delete(:detail_level) || 'basic'
    @config.delete(:icon_emoji) if @config[:icon_url] && @config[:icon_emoji]
  end

  def report
    begin
      Timeout::timeout(@timeout) do
        Chef::Log.debug("Sending report to Slack ##{config[:channel]}@#{team}.slack.com")
        if fail_only
          unless run_status.success?
            slack_message("Chef client run #{run_status_human_readable} on #{run_status.node.name} #{run_status_detail} \n #{run_status.exception}")
          end
        else
          slack_message("Chef client run #{run_status_human_readable} on #{run_status.node.name} #{run_status_detail}")
        end
      end
    rescue Exception => e
      Chef::Log.debug("Failed to send message to Slack: #{e.message}")
    end
  end

  private

  def run_status_detail
    case detail_level
    when "basic"
      return
    when "elapsed"
      "(#{run_status.elapsed_time} seconds). #{updated_resources.count} resources updated"  unless updated_resources.nil?
    when "resources"
      "(#{run_status.elapsed_time} seconds). #{updated_resources.count} resources updated\n#{updated_resources.join(", ").to_s}"  unless updated_resources.nil?
    else
      return
    end
    return
  end

  def slack_message(content)
    slack = Slackr::connect(team, api_key, config)
    slack.say(content)
  end

  def run_status_human_readable
    run_status.success? ? "succeeded" : "failed"
  end

end
