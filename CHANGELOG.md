# Changelog

## 0.9.1

- Fix for syntax issue (#54)

## 0.9.0

- check Chef for run_context compatibility (#52)
- Disable Slack handler in why-run mode (#49)
- Fix a few of the additional lint complaints (#47)

## 0.8.1

- Pins chef_handler version (#46)
- Fix reporting exceptions with libyajl2 (#42)
- Testing Cleanup (#40)
- Add channel as channel can be overridden with a webhook (#39)

## 0.8.0
- Check slack webhook result; move run status to property (#35)
- Added send_organization configuration which provides the optional ability to include the organization in /etc/chef/client.rb to Slack.
- webhook: check http response (#30)

## 0.7.1
- Version 0.7.0 broke most of the `message_detail_level` settings, only `basic` worked. 0.7.1 fixes it.

## 0.7.0
- Added `send_start_message` configuration which if set to `true` sends out a message when this cookbook is run. This is not quite the same as a [Chef start handler](https://docs.chef.io/handlers.html) but requires no additional setup to run. If you have other start handlers registered, they may run twice due if you turn this setting on. Default setting is `false`.
- Added `send_environment` configuration which if set to `true` sends the node.chef_environment. Default setting is `false`.

## v0.6.0
- Fix a bug in run_context where we should be calling `Chef.run_context`, correct an incorrect method name. (#22)

## v0.5.0
- Added `cookbook_detail_level` configuration which provides the optional ability to include a list of all cookbooks used in the message to Slack. Values inside README.md (#17)
- Some defaults have been removed from the WebHook integration to allow Slack WebHook default configuration to be used, can still be overridden (#16). The slackr integration remains the same. Specifically:
  - `username` no longer defaults to `node.name`
  - `username` no longer defaults to `chef_handler`
  - `icon_emoji` no longer defaults to `:fork_and_knife:`
- Changed `detail_level` to `message_detail_level` in order to clarify its meaning against `cookbook_detail_level`
- Optional `fail_only`, `message_detail_level` and `cookbook_detail_level` attributes for WebHook can now drop down to global attributes (#18)
- `icon_url` now works as expected for WebHook configuration (#15)
- Clarified items in README.md including `channel` being mandatory for the slackr integration; presence of optional `timeout` attribute; what the defaults are (#21)

## v0.4.0 (2016-03-09)
- Add CHANGELOG.md (#11)
- Move exception from message to text attachment (#12)

## v0.3.0 (2016-02-18)
- Downgrade level of the webhook log message from `warn` to `info`

## v0.2.0 (2016-02-01)
- Add Rubocop and Foodcritic
- Fix ruby syntax
- Fix bug when not using webhooks
- Add circle.yml for CircleCI
- Webhook handler honors `:icon_url` attribute

## v0.1.0 (2015-05-25)
- Initial release to Supermarket at [f32996d](https://github.com/rackspace-cookbooks/chef-slack_handler/commit/f32996d)

## Forked
Forked from [dcm-ops/chef-slack_handler](https://github.com/dcm-ops/chef-slack_handler) on 2015-05-18.
