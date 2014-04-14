Description
===========

A cookbook for a `chef_handler` that sends reports and exceptions to Slack using an integration webhook.

Requirements
============

* The `chef_handler` cookbook
* An existing Slack incoming webhook

Attributes
==========

This cookbook uses the following attributes to configure how it is installed.

* `node['chef_client']['handler']['slack']['team']` - Your Slack team name (<team-name>.slack.com)
* `node['chef_client']['handler']['slack']['api_key']` - The API key of your Slack incoming webhook 

Optional attributes

* `node['chef_client']['handler']['slack']['channel']` - The #channel to send the results
* `node['chef_client']['handler']['slack']['username']` - The username of the Slack message
* `node['chef_client']['handler']['slack']['icon_url']` - The Slack message icon
* `node['chef_client']['handler']['slack']['icon_emoji']` - The Slack message icon defined by available `:emoji:`

NOTE: Either `icon_url` or `icon_emoji` can be used. If both are set, `icon_url` will take precedence.

Usage
=====

1. Create a new Slack webhook ([https://slack.com/services/new/incoming-webhook](https://slack.com/services/new/incoming-webhook))
2. Set the `team` and `api_key` attributes above on the node/environment/etc.
3. Include this `slack_handler` recipe.

Credits
=======

Borrowed everything from the `logstash_handler` cookbook [here](https://github.com/lusis/logstash_handler), who in turn borrowed quite a bit from the `graphite_handler` cookbook [here](https://github.com/realityforge-cookbooks/graphite_handler).

License
=======

`slack_handler` is provided under the Apache License 2.0. See `LICENSE` for details.
