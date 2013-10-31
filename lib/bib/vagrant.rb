require "bib/vagrant/version"
require "bib/vagrant/config"
require "thor"

class BibVagrant < Thor
  package_name 'bib-vagrant'

  desc 'show', 'show configuration settings'
  def show
    config = get_wrapper

    puts "Your configuration is located in: #{config.get_path}"
    puts ""

    config.get.each do |config_key,config_value|
      puts "#{config_key}: #{config_value}"
    end
  end

  desc 'setup', 'setup local configuration with default values'
  def setup
    config = Bib::Vagrant::Config.new
    raise "Your configuration is already created: #{config.get_path}" if config.has?

    config.get

    puts "Configuration created in #{config.get_path}!"
  end

  private
  def get_wrapper
    config = Bib::Vagrant::Config.new
    raise "No configuration, run `bib-vagrant setup`!" unless config.has?
    config
  end
end
