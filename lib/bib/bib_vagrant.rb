require 'yaml'

module Bib
  module Vagrant
    # Checks for plugins and takes a plugin list plus optional true/false for checking some
    # _esoteric_ plugin constellation, see Bib::Vagrant#check_esoteric_plugin_constellation.
    #
    # ==== Example where given plugins are all mandatory (plugins are given as an array)
    #
    #   Bib::Vagrant.check_plugins(['landrush', 'vagrant-hosts'])
    #
    # ==== Example where a plugin may be mandatory but doesn't need to (plugins are given as a hash)
    #
    #   Bib::Vagrant.check_plugins(
    #     {
    #       'landrush' => true,
    #       'vagrant-hosts' => false
    #     },
    #     true
    #   )
    def self.check_plugins(plugins, check_esoteric_plugin_constellation = true)
      complete = true

      plugins.each do |plugin, mandatory|
        next if ::Vagrant.has_plugin?(plugin)
        next if ENV['VAGRANT_CI']
        puts "!!! - You are missing a plugin: #{plugin}"
        puts '---'
        puts "### - Please run: vagrant plugin install #{plugin}"
        puts '---'
        puts "!!! - Read more here: #{plugin_list[plugin]}"
        complete = false if mandatory
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

    # Returns an array which lists plugins to check where index is the name of the plugin and value
    # is the url where the user can get more information about it.
    def self.plugin_list
      {
        'landrush' => 'https://github.com/phinze/landrush',
        'vagrant-hosts' => 'https://github.com/adrienthebo/vagrant-hosts',
        'vagrant-faster' => 'https://github.com/rdsubhas/vagrant-faster#how-much-does-it-allocate',
        'vagrant-cachier' => 'https://github.com/easybib/issues/wiki/Knowledgebase:-Global-Vagrant-setup#enable-vagrant-cachier-globally',
        'bib-vagrant' => 'See https://github.com/easybiblabs/bib-vagrant/blob/master/README.md'
      }
    end
  end
end
