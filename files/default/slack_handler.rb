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
require_relative 'slack_handler_util'

class Chef::Handler::Slack < Chef::Handler
  attr_reader :team, :api_key, :config, :timeout, :fail_only, :message_detail_level, :cookbook_detail_level

  def initialize(config = {})
    Chef::Log.debug('Initializing Chef::Handler::Slack')
    @util = SlackHandlerUtil.new(config)
    @config = config
    setup_slackr_options(@config)

    @team = @config[:team]
    @api_key = @config[:api_key]
    @timeout = @config[:timeout]
    @fail_only = @config[:fail_only]
    @message_detail_level = @config[:message_detail_level]
    @cookbook_detail_level = @config[:cookbook_detail_level]
  end

  def report
    Timeout.timeout(@timeout) do
      sending_to_slack = if run_status.is_a?(Chef::RunStatus)
                           report_chef_run_end
                         else
                           report_chef_run_start
                         end
      Chef::Log.debug("Saying report to Slack channel ##{config[:channel]} on team #{team}.slack.com") if sending_to_slack
    end
  rescue Exception => e
    Chef::Log.debug("Failed to send message to Slack: #{e.message}")
  end

  private

  def setup_slackr_options(config = {})
    # options to be passed to slackr gem
    @slackr_options = {}
    # icon_url takes precedence over icon_emoji
    if config[:icon_url]
      @slackr_options[:icon_url] = config[:icon_url]
    elsif config[:icon_emoji]
      @slackr_options[:icon_emoji] = config[:icon_emoji]
    end
    @slackr_options[:channel] = config[:channel]
    @slackr_options[:username] = config[:username]
  end

  def report_chef_run_start
    return false unless @util.send_on_start
    slack_message(@util.start_message.to_s, run_status.node.name)
  end

  def report_chef_run_end
    if run_status.success?
      return false if @util.fail_only
      slack_message("#{@util.end_message(run_status)} \n #{run_status.exception}", run_status.node.name)
    else
      slack_message(@util.end_message(run_status).to_s, run_status.node.name)
    end
  end

  def slack_message(content, node_name)
    Chef::Log.debug("Saying slack message #{content}")
    @slackr_options[:username] = node_name unless @slackr_options[:username]
    slack = Slackr.connect(team, api_key, @slackr_options)
    slack.say(content)
  end
end
