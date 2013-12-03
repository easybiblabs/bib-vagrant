# Bib::Vagrant

[![Build Status](https://travis-ci.org/easybiblabs/bib-vagrant.png?branch=master)](https://travis-ci.org/easybiblabs/bib-vagrant)
[![Coverage Status](https://coveralls.io/repos/easybiblabs/bib-vagrant/badge.png)](https://coveralls.io/r/easybiblabs/bib-vagrant)

This is a work in progress - and subject to [additions and changes](CONTRIBUTING.md).

## Objective

 1. Remove developer-specific settings from a project's `Vagrantfile`.
 2. Streamline setup/onboarding.
 3. Avoid stale settings all around.

## Installation

Install the plugin:

    $ vagrant plugin install bib-vagrant

## Usage

In your `Vagrantfile`:

```ruby
Vagrant.require_plugin 'bib-vagrant'

Vagrant.configure("2") do |config|
  bibconfig = Bib::Vagrant::Config.new
  vagrantconfig = bibconfig.get

  config.vm.define :db do |web_config|

    #...

    web_config.vm.provider :virtualbox do |vb|
      vb.gui = vagrantconfig["gui"]
      #...
    end

    web_config.vm.synced_folder "./../", "/vagrant_data", :owner => "vagrant", :nfs => vagrantconfig["nfs"]

    web_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = vagrantconfig["cookbook_path"]
      chef.add_recipe "something::here"
      chef.log_level = vagrantconfig["chef_log_level"]
    end

  end
```

The configuration is located in `~/.config/easybib/vagrantdefault.yml`:

```yaml
---
nfs: false
cookbook_path: ~/Documents/workspaces/easybib-cookbooks
chef_log_level: debug
additional_json: ! '{}'
gui: true
```

## Contributing

See [Contributing](CONTRIBUTING.md)

