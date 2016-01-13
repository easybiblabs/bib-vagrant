require 'vagrant'
require 'rubygems'
require 'rest_client'
require 'json'
require 'base64'

String.class_eval do
  def is_valid_url?
    uri = URI.parse self
    uri.is_a? URI::HTTP
  rescue URI::InvalidURIError
    false
  end
end

# Define the provisioner.
# do this outside of the bib::vagrant module for ease of calling
class BibConfigurePlugin < Vagrant.plugin('2')
  name 'NPM configuration Provisioner'

  # This plugin provides a provisioner called unix_reboot.
  provisioner 'bib_configure_npm' do
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

        # sneaky fix to "stdin: is not a tty" noise
        # sudo_command("sudo sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile")

        # inbound variables
        registry = false
        username = false
        usermail = false
        userpass = false

        if bib_config_values.include?('npm_registry')
          registry = bib_config_values['npm_registry'].clone
        end

        if bib_config_values.include?('npm_username')
          username = bib_config_values['npm_username'].clone
        end

        if bib_config_values.include?('npm_usermail')
          usermail = bib_config_values['npm_usermail'].clone
        end

        if bib_config_values.include?('npm_userpass')
          userpass = bib_config_values['npm_userpass'].clone
        end

        if registry && username && usermail && userpass
          auth_hash = Base64.strict_encode64(username + ':' + userpass)
          auth_token = get_npm_token(registry, username, usermail, userpass)
          if auth_token
            registry_ident = registry.clone
            registry_ident.slice!('http:')

            npmrc_set('always-auth', 'true')
            npmrc_set('registry', registry)
            npmrc_set('email', usermail)

            # this seems to break 1.4.x (it gets username from _auth base64)
            # npmrc_set('username', username)

            # for older npm user/pass hash authentication
            npmrc_set('_auth', '"' + auth_hash + '"')

            # for newer npm token authentication
            npmrc_set(registry_ident + ':_authToken', '"' + auth_token + '"')

          else
            @machine.ui.info('npm registry token request failed. Attempting old style auth configuration.')
            npmrc_set('always-auth', 'true')
            npmrc_set('registry', registry)
            npmrc_set('email', usermail)

            # this seems to break 1.4.x (it gets username from _auth base64)
            # npmrc_set('username', username)

            npmrc_set('_auth', auth_hash)
          end

        else

          message = ''
          message += ' npm_registry' unless registry

          message += ' npm_username' unless username

          message += ' npm_userpass' unless usermail

          message += ' npm_userpass' unless userpass

          @machine.ui.warn('WARNING: Missing ' + message + ' value(s) in ~/.config/easybib/vagrantdefault.yml (On your HOST OS)')
          @machine.ui.warn('WARNING: .npmrc not setup on your guest OS')
        end

        # if bib_config_values.includ?('composer_github_token')
        #   composer_set('github-oauth.github.com', bib_config_values['composer_github_token'])
        # else
        #   @machine.ui.warn("Missing composer_github_token value in config")
        # end

        send_command('mkdir -p ~/.npm/_locks')
        send_command('sudo chown -R $USER ~/.npm')

        # Now the machine is up again, perform the necessary tasks.
        @machine.ui.info('bib-vagrant config complete...')
      end

      # def composer_set(key, value)
      #   command = "composer config -g #{key} #{value}"
      #   sudo_command(command)
      # end

      def npmrc_set(key, value)
        command = 'npm -g config '
        if value
          command << "set #{key} #{value}"
        else
          # if value is null assume a delete
          command << "delete #{key}"
          # fix for npmrc key not existing
          sudo_command("npm -g set #{key} GNDN")
        end
        # do not to echo the command all the time (need if debug?)
        # @machine.ui.info(command)
        sudo_command(command)
      end

      def send_command(command)
        @machine.communicate.execute(command) do |type, data|
          if type == :stderr
            @machine.ui.warn(data)
          else
            @machine.ui.info(data)
          end
        end
      end

      def sudo_command(command)
        @machine.communicate.sudo(command) do |type, data|
          if type == :stderr
            @machine.ui.warn(data)
          else
            @machine.ui.info(data)
          end
        end
      end

      # my nifty function to get an NPM token from the registry
      def get_npm_token(registry_url, username, usermail, userpass)
        # get the date for some reason
        date = Time.now
        # set up the request _id ???
        _id = 'org.couchdb.user:' + username
        # set up the registry URL to request the token from
        url = registry_url + '-/user/' + _id
        # create json object passed to the registry
        data = {  _id: _id,
                  name: username,
                  password: userpass,
                  email: usermail,
                  type: 'user',
                  roles: [],
                  date: date
            }
        # convert it to json
        jdata = JSON.generate(data)
        # make the request and see if we get a token
        puts 'get user token'
        puts url
        if url.is_valid_url?
          begin
            response_json = RestClient.put url, jdata, content_type: :json
            # convert the response to a hash???
            hash = JSON.parse response_json
            # check to see if the key token is there
            if hash.key?('token')
              # it is, so return it
              hash['token']
            else
              # it doesn't so return false
              false
            end
          rescue => error
            # not a valid connection
            puts 'WARNING: could not connect to ' + url + ' to exchange tokens'
            false
          end

        else
          # not a valid URL
          puts 'WARNING: ' + url + ' does not seem to be valid'
          false
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
