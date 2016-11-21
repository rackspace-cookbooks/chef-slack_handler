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
require 'net/http'
require "timeout"
require_relative 'slack_handler_util'

class Chef::Handler::Slack < Chef::Handler
  attr_reader :webhooks, :username, :config, :timeout, :icon_emoji, :fail_only, :message_detail_level, :cookbook_detail_level

  def initialize(config = {})
    Chef::Log.debug('Initializing Chef::Handler::Slack')
    @config = config
    @timeout = @config[:timeout]
    @icon_emoji = @config[:icon_emoji]
    @icon_url = @config[:icon_url]
    @channel = @config[:channel]
    @username = @config[:username]
    @webhooks = @config[:webhooks]
    @fail_only = @config[:fail_only]
    @message_detail_level = @config[:message_detail_level]
    @cookbook_detail_level = @config[:cookbook_detail_level]
  end

  def setup_run_status(run_status)
    @run_status = run_status
    @util = SlackHandlerUtil.new(@config, @run_status)
  end

  def report
    setup_run_status(run_status)

    @webhooks['name'].each do |val|
      Chef::Log.debug("Sending handler report to webhook #{val}")
      webhook = node['chef_client']['handler']['slack']['webhooks'][val]
      Timeout.timeout(@timeout) do
        sending_to_slack = if @run_status.is_a?(Chef::RunStatus)
                             report_chef_run_end(webhook)
                           else
                             report_chef_run_start(webhook)
                           end
        Chef::Log.info("Sending report to Slack webhook #{webhook['url']}") if sending_to_slack
      end
    end
  rescue Exception => e
    Chef::Log.warn("Failed to send message to Slack: #{e.message}")
  end

  private

  def report_chef_run_start(webhook)
    return false unless @util.send_on_start(webhook)
    slack_message(" :gear: #{@util.start_message(webhook)}", webhook['url'])
  end

  def report_chef_run_end(webhook)
    if @run_status.success?
      return false if @util.fail_only(webhook)
      slack_message(" :white_check_mark: #{@util.end_message(webhook)}", webhook['url'])
    else
      slack_message(" :skull: #{@util.end_message(webhook)}", webhook['url'], run_status.exception)
    end
  end

  def slack_message(message, webhook, text_attachment = nil)
    Chef::Log.debug("Sending slack message #{message} to webhook #{webhook} #{text_attachment ? 'with' : 'without'} a text attachment")
    uri = URI.parse(webhook)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    req.body = request_body(message, text_attachment)
    res = http.request(req)
    # responses can be:
    # "Bad token"
    # "invalid_payload"
    # "ok"
    raise res.body unless res.body == 'ok'
  end

  def request_body(message, text_attachment)
    body = {}
    body[:username] = @username unless @username.nil?
    body[:text] = message
    # icon_url takes precedence over icon_emoji
    if @icon_url
      body[:icon_url] = @icon_url
    elsif @icon_emoji
      body[:icon_emoji] = @icon_emoji
    end
    body[:channel] = @channel if @channel
    body[:attachments] = [{ text: text_attachment.to_s }] unless text_attachment.nil?
    body.to_json
  end
end
