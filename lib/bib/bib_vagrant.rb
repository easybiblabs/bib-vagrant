require 'yaml'


class String
  def red
    "\033[31m#{self}\033[0m"
  end
end


module Bib
  module Vagrant
    class << self
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
      def check_plugins(plugins, check_esoteric_plugin_constellation = true)
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
      def check_esoteric_plugin_constellation
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
      def plugin_list
        {
          'landrush' => 'https://github.com/phinze/landrush',
          'vagrant-hosts' => 'https://github.com/adrienthebo/vagrant-hosts',
          'vagrant-faster' => 'https://github.com/rdsubhas/vagrant-faster#how-much-does-it-allocate',
          'vagrant-cachier' => 'https://github.com/easybib/issues/wiki/Knowledgebase:-Global-Vagrant-setup#enable-vagrant-cachier-globally',
          'bib-vagrant' => 'See https://github.com/easybiblabs/bib-vagrant/blob/master/README.md',
          'vagrant-logs' => 'See https://github.com/easybiblabs/vagrant-logs/blob/master/README.md'
        }
      end

      def init_github_hostkey(machine)
        machine.vm.provision 'shell' do |s|
          s.inline = 'ssh -T git@github.com -o StrictHostKeyChecking=no; exit 0'
          s.privileged = false
        end
      end

      def check_gatling
        unless ::Vagrant.has_plugin?('vagrant-gatling-rsync')
          puts "\nERROR: you're using rsync - you'll need the vagrant-gatling-rsync plugin\n"
          puts 'do'
          puts "\n\tvagrant plugin install vagrant-gatling-rsync\n\n"
          puts "(also: see the README for how to increase the inotify limit)\n"
          exit 1
        end
        puts "\nNOTE: you're using rsync, run\n\n\tvagrant gatling-rsync-auto\n\nto auto-sync the shared folders\n\n"
      end

      def install_node_artifacts(machine, node_uri)
        machine.vm.provision 'shell', inline: <<-SHELL
            echo "grabbing /usr/lib/node_modules.."
            sudo wget --continue -O /tmp/usr_node.tgz #{node_uri}
            sudo mkdir -p /usr/lib/node_modules
            sudo tar --overwrite -zxof /tmp/usr_node.tgz -C /usr/lib/
            echo ".. done."
        SHELL
      end

      def add_composertoken_to_dna(dna, vagrantconfig)
        if vagrantconfig.key?('composer_github_token') && !vagrantconfig['composer_github_token'].empty?
          puts "[info] Replacing OAuth2 Token for composer with user token: #{vagrantconfig['composer_github_token']}"
          dna['composer']['oauth_key'] = vagrantconfig['composer_github_token']
        else
          puts "[error] You don't have a token setup in!".red
          puts ' 1. https://github.com/settings/tokens (with repo scope only)'
          puts ' 2. Add this line to ~/.config/easybib/vagrantdefault.yml:'
          puts ' composer_github_token: your-token-here'
          puts ''
          puts "Run `vagrant #{ARGV[0]}` again!"
          exit
        end
        dna
      end

      def prepare_app_settings(vagrantconfig, machine, dna, applicationlist = 'applications')
        dna = add_composertoken_to_dna(dna, vagrantconfig)
        dna['vagrant'][applicationlist].each do |app, app_config|
          vagrant_share = File.expand_path(app_config['app_root_location'])
          host_folder = "#{File.dirname(__FILE__)}/sites/#{app}"
          if vagrantconfig['nfs']
            machine.vm.synced_folder host_folder, vagrant_share, type: 'nfs', mount_options: ['nolock,vers=3,udp,noatime,actimeo=1']
          elsif vagrantconfig['rsync']
            machine.vm.synced_folder host_folder, vagrant_share, type: 'rsync'
          else
            machine.vm.synced_folder host_folder, vagrant_share, owner: 'vagrant'
          end
        end
        dna
      end

      def setup_landrush_hostnames(config, host_ip, dna, applicationlist = 'applications')
        hosts_list = []

        dna['vagrant'][applicationlist].each do |_app, app_config|
          # Populate Landrush and vagrant-hosts
          host_name = "#{app_config['domain_name']}"
          hosts_list.push(host_name)
          config.landrush.host host_name, host_ip
        end

        # This loop will actually populate the /etc/hsots on the guest and host OS via vagrant-hosts
        hosts_flat = hosts_list.map { |name| name.split(' ') }.flatten.uniq
        config.vm.provision :hosts do |provisioner|
          # Add a single hostname
          provisioner.add_host host_ip, hosts_flat
        end
      end

      def default_provision(machine)
        # remove locale passing via ssh also generate a default locale on the guest OS
        machine.vm.provision 'shell', inline: 'sed -i "s/@AcceptEnv LANG LC_\*/# AcceptEnv LANG LC_\*/g" /etc/ssh/sshd_config'
        machine.vm.provision 'shell', inline: 'locale-gen en_US.UTF-8'

        # uncomment the next line and re-run provision if you end up with a
        # "Failed to fetch mirror://mirrors.ubuntu.com/mirrors.txt" error:
        # machine.vm.provision "shell", inline: "apt-spy2 fix --commit --launchpad --country=US"
        # machine.vm.provision "shell", inline: "apt-spy2 fix --commit --launchpad --country=Germany"

        machine.vm.provision 'shell', inline: 'apt-get update -y'
      end
    end
  end
end
