require 'yaml'

module Bib
  module Vagrant
    # Checks for plugins and takes a plugin list plus optional true/false for checking some
    # _esoteric_ plugin constellation, see Bib::Vagrant#check_esoteric_plugin_constellation.
    #
    # ==== Example
    #
    #   Bib::Vagrant.check_plugins(
    #     {
    #       'landrush' => {
    #       'url' => 'https://github.com/phinze/landrush',
    #       'mandatory' => true
    #     },
    #       'vagrant-hosts' => {
    #       'url' => 'https://github.com/adrienthebo/vagrant-hosts',
    #       'mandatory' => true
    #     },
    #     false
    #   )
    def self.check_plugins(plugins, check_esoteric_plugin_constellation = true)
      complete = true

      plugins.each do |plugin, info|
        next if ::Vagrant.has_plugin?(plugin)
        next if ENV['VAGRANT_CI']
        url = info['url']
        puts "!!! - You are missing a plugin: #{plugin}"
        puts '---'
        puts "### - Please run: vagrant plugin install #{plugin}"
        puts '---'
        puts "!!! - Read more here: #{url}"
        complete = false if info['mandatory']
      end

      if check_esoteric_plugin_constellation
        complete = self.check_esoteric_plugin_constellation ? complete : false
      end

      complete
    end

    # Checks for some _esoteric_ plugin constellation.
    #
    # Please follow the output instructions when the _esoteric_ constellation is met.
    def self.check_esoteric_plugin_constellation
      complete = true

      if ::Vagrant.has_plugin?('landrush') && !Gem.loaded_specs['celluloid'].nil?
        if Gem.loaded_specs['celluloid'].version.to_s == '0.16.1'
          puts 'This is an esoteric issue for vagrant 1.7.4/landrush 18 and virtualbox 5.x'
          puts 'celluloid is 0.16.1'
          puts 'Please do the following on your HOST OS'
          puts '    export GEM_HOME=~/.vagrant.d/gems'
          puts '    gem uninstall celluloid -v 0.16.1'
          puts '    gem install celluloid -v 0.16.0'
          complete = false
        end
      end

      complete
    end
  end
end
