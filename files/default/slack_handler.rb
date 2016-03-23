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
  attr_reader :team, :api_key, :config, :timeout, :fail_only, :message_detail_level, :cookbook_detail_level

  def initialize(config = {})
    Chef::Log.debug('Initializing Chef::Handler::Slack')
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
      Chef::Log.debug("Saying report to Slack channel ##{config[:channel]} on team #{team}.slack.com")
      if fail_only
        unless run_status.success?
          slack_message("#{message(config)} \n #{run_status.exception}", run_status.node.name)
        end
      else
        slack_message(message(config).to_s, run_status.node.name)
      end
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

  def message(context)
    "Chef client run #{run_status_human_readable} on #{run_status.node.name}#{run_status_cookbook_detail(context['cookbook_detail_level'])}#{run_status_detail(context['message_detail_level'])}"
  end

  def run_status_detail(message_detail_level)
    case message_detail_level
    when "elapsed"
      " (#{run_status.elapsed_time} seconds). #{updated_resources.count} resources updated" unless updated_resources.nil?
    when "resources"
      " (#{run_status.elapsed_time} seconds). #{updated_resources.count} resources updated\n#{updated_resources.join(', ')}" unless updated_resources.nil?
    end
  end

  def slack_message(content, node_name)
    Chef::Log.debug("Saying slack message #{content}")
    @slackr_options[:username] = node_name unless @slackr_options[:username]
    slack = Slackr.connect(team, api_key, @slackr_options)
    slack.say(content)
  end

  def run_status_human_readable
    run_status.success? ? "succeeded" : "failed"
  end

  def run_status_cookbook_detail(cookbook_detail_level)
    case cookbook_detail_level
    when "all"
      cookbooks = run_status.run_context.cookbook_collection
      " using cookbooks #{cookbooks.values.map { |x| x.name.to_s + ' ' + x.version }}"
    end
  end
end
