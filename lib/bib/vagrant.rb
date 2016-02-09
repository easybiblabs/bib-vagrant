require_relative 'version'
require_relative 'bib_vagrant'
require_relative 'bib_vagrant_config'
require_relative 'bib_vagrant_npm_provisioner'

require 'thor'

class BibVagrant < Thor
  package_name 'bib-vagrant'

  desc 'validate', 'validate the local configuration'
  def validate
    config = get_wrapper
    vagrant_defaults = config.get
    config.validate!(vagrant_defaults)
  end

  desc 'show', 'show configuration settings'
  def show
    config = get_wrapper
    puts "Your configuration is located in: #{config.get_path}"
    puts ''
    config.get.each do |config_key, config_value|
      puts "#{config_key}: #{config_value}"
    end
  end

  desc 'setup', 'setup local configuration with default values'
  def setup
    config = Bib::Vagrant::Config.new
    fail "Your configuration is already created: #{config.get_path}" if config.has?
    config.get
    puts "Configuration created in #{config.get_path}!"
  end

  private

  def get_wrapper
    config = Bib::Vagrant::Config.new
    fail 'No configuration, run `bib-vagrant setup`!' unless config.has?
    config
  end
end
