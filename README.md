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

Do not use this command in a directory with a Vagrantfile which requires the plugin. Vagrant does _always_ include the Vagrantfile, and therefore will fail before installation because of the missing plugin. Just ```cd``` somewhere else and retry the command, maybe from your homedir?

## Usage

### Developer Settings
The config file with all developer specific settings is currently ```~/.config/easybib/vagrantdefault.yml```. If no such file exists, the plugin will create the file with default settings.

The content of this file can be retrieved using the plugin as an array, the the Vagrantfile-Example below for usage.

The current default settings and their respective usage in our Vagrantfiles are:

```

#Use filesystem shares over nfs
nfs: false

#Path to the cookbooks
cookbook_path: ~/Sites/easybib/cookbooks

#Chef Log Level
chef_log_level: debug

#Additional JSON to be merged in the Chef JSON
additional_json: ! '{}'

#Show Virtualbox GUI
gui: false

# Token to use with composer
composer_github_token: <github token>

# npm proxy in the form of "http://npm-proxy.tld/"
npm_registry: <npm registry or proxy url>

# your npm user email address in the form of user@domain.tld
npm_username: <github or npm username>

# your npm or user email address in the form of user@domain.tld
npm_usermail: <npm or github users email address>

# Authentication Token to use with npm
npm_userpass: <npm or github authentication token>


```

Additional parameters can be added to the file and used in the Vagrantfile - but you then have to make sure to use sensible fallback defaults in your Vagrantfile, since not every developer might have this setting in the .yml.


### Vagrantfile

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

    web_config.vm.provision "bib_configure_npm"

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
composer_github_token: <github token>
npm_registry: <npm registry or proxy url>
npm_username: <github or npm username>
npm_usermail: <npm or github users email address>
npm_userpass: <npm or github authentication token>
```

NOTE: the npm_registry should be in the format of 'http[s]://host.domain.tld/' - The trailing slash is important

## Developing and Testing

Make sure you are using a Bundler version which is compatible with Vagrant which comes from GitHub like defined here:

```
group :development do
  gem 'vagrant', git: 'https://github.com/mitchellh/vagrant.git'
end
```

Bundler version 1.7.15 works fine and can be installed like this:

```
gem install bundler -v '~> 1.7.0'
```

Then, when you want to test Bib Vagrant use:

```
bundle _1.7.15_ exec vagrant
```

Happy developing and testing.

## Contributing

See [Contributing](CONTRIBUTING.md)
