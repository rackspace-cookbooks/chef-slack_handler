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

class Chef::Handler::Slack < Chef::Handler
  attr_reader :webhooks, :username, :config, :timeout, :icon_emoji, :fail_only, :detail_level

  def initialize(config = {})
    # set defaults for any missing attributes
    @config = config
    @timeout = @config[:timeout] || 15
    @icon_emoji = @config[:icon_emoji] || ':fork_and_knife:'
    @username = @config[:username] || 'chef_handler'
    @webhooks = @config[:webhooks]
  end

  def report
    @webhooks['name'].each do |val|
      webhook = node['chef_client']['handler']['slack']['webhooks'][val]
      Timeout.timeout(@timeout) do
        sending_to_slack = false

        if run_status.success?
          unless webhook['fail_only']
            slack_message(" :white_check_mark: Chef client run #{run_status_human_readable} on #{run_status.node.name} #{run_status_detail(webhook['detail_level'])}", webhook['url'])
            sending_to_slack = true
          end
        else
          sending_to_slack = true
          slack_message(" :skull: Chef client run #{run_status_human_readable} on #{run_status.node.name} #{run_status_detail(webhook['detail_level'])}", webhook['url'], run_status.exception)
        end
        Chef::Log.info("Sending report to Slack webhook #{webhook['url']}") if sending_to_slack
      end
    end
  rescue Exception => e
    Chef::Log.warn("Failed to send message to Slack: #{e.message}")
  end

  private

  def run_status_detail(detail_level)
    case detail_level
    when "basic"
      return
    when "elapsed"
      "(#{run_status.elapsed_time} seconds). #{updated_resources.count} resources updated" unless updated_resources.nil?
    when "resources"
      "(#{run_status.elapsed_time} seconds). #{updated_resources.count} resources updated \n #{updated_resources.join(', ')}" unless updated_resources.nil?
    else
      return
    end
  end

  def slack_message(message, webhook, text_attachment = nil)
    uri = URI.parse(webhook)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    req.body = request_body(message, text_attachment)
    http.request(req)
  end

  def request_body(message, text_attachment)
    body = {}
    body[:username] = @username
    body[:text] = message
    if @icon_url
      body[:icon_url] = @icon_url
    else
      body[:icon_emoji] = @icon_emoji
    end
    body[:attachments] = [{ text: text_attachment }] unless text_attachment.nil?
    body.to_json
  end

  def run_status_human_readable
    run_status.success? ? "succeeded" : "failed"
  end
end
