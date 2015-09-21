
require 'vagrant'

# Define the plugin.
class BibConfigurePlugin < Vagrant.plugin('2')
  name 'NPM Plugin'

  # This plugin provides a provisioner called unix_reboot.
  provisioner 'bib_configure' do
 
    # Create a provisioner.
    class BibConfigureProvisioner < Vagrant.plugin('2', :provisioner)
      # Initialization, define internal state. Nothing needed.

      attr_reader :bib_config

      def initialize(machine, config)
        super(machine, config)
      end
 
      # Configuration changes to be done. Nothing needed here either.
      def configure(root_config)
        super(root_config)
      end
 
      # Run the provisioning.
      def provision
        return unless @machine.communicate.ready?
        bib_config = Bib::Vagrant::Config.new
        bib_config_values = bib_config.get
        bib_config.validate!(bib_config_values)

        if bib_config_values.include?('npm_auth')
          npmrc_set_or_delete('_auth',bib_config_values['npm_auth'])
        else
          @machine.ui.error("Missing npm_auth value in config")
        end

        if bib_config_values.include?('npm_registry')
          npmrc_set_or_delete('registry',bib_config_values['npm_registry'])
        else
          @machine.ui.error("Missing npm_registry value in config")
        end

        if bib_config_values.include?('npm_email')
          npmrc_set_or_delete('email',bib_config_values['npm_email'])
        else
          @machine.ui.error("Missing npm_email value in config")
        end

        if bib_config_values.include?('npm_always-auth')
          npmrc_set_or_delete('always-auth',bib_config_values['npm_always-auth'])
        else
          @machine.ui.error("Missing npm_always-auth value in config")
        end

        # send_command('npm config ls')
        # send_command('npm -d view npm')
  
        # Now the machine is up again, perform the necessary tasks.
        @machine.ui.info('bib-vagrant config complete...')
      end

      # composer config -g github-oauth.github.com <oauthtoken>

      def npmrc_set_or_delete(key, value)
        command = "sudo npm -g "
        if value
          command << "set #{key} #{value}"
        else
          command << "delete #{key}"
          # fix for npmrc key not existing
          send_command("sudo npm -g set #{key} GNDN")
        end
        send_command(command)
      end

      def send_command(command) 
        @machine.communicate.sudo(command) do |type, data|
          if type == :stderr
            @machine.ui.error(data)
          else
            @machine.ui.info(data)
          end
        end

      end

      # Nothing needs to be done on cleanup.
      def cleanup
        super
      end
    end
    BibConfigureProvisioner
  end
end

