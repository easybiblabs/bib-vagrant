require 'yaml'

module Bib
  module Vagrant
    class Config

      @@home_dir = nil
      @@verbose = true

      def initialize(home = "~", verbose = true)
        @@home = home
        @@verbose = verbose
      end

      def get

        vagrantconfig = get_defaults

        begin
          localconfigfile = File.open(get_path, 'r')
          vagrantconfig.merge!(YAML.load(localconfigfile.read))
        rescue Errno::ENOENT
          puts 'WARNING: No vagrant user-config found, using default cookbook path' if @@verbose
          create(get_path, vagrantconfig)
        end

        return vagrantconfig
      end

      def has?
        File.exists?(get_path)
      end

      def get_path
        File.expand_path("#{@@home}/.config/easybib/vagrantdefault.yml")
      end

      def validate!(config)

        current_config_keys = config.keys

        get_defaults.keys.each do |required_key|
          raise "Missing #{required_key}!" unless current_config_keys.include?(required_key)
        end

        errors = []
        log_level = ['debug', 'info', 'warn', 'error', 'fatal']

        errors << "nfs: must be a boolean" unless [TrueClass, FalseClass].include?(config['nfs'].class)
        errors << "gui: must be a boolean" unless [TrueClass, FalseClass].include?(config['gui'].class)
        errors << "cookbook_path: does not exist" unless File.directory?(config['cookbook_path'])
        errors << "chef_log_level: must be one of #{log_level.join}" unless log_level.include?(config['chef_log_level'])

        if errors.count == 0
          return
        end

        raise "Errors: #{errors.join(', ')}"
      end

      private
      def create(localconfigpath, vagrantconfig)
        begin
          FileUtils.mkdir_p(File.dirname(localconfigpath))
          File.open(localconfigpath, 'w+') do |file|
            file.write( vagrantconfig.to_yaml )
            puts "INFO: Created default vagrant user-config in #{localconfigpath}" if @@verbose
            puts "INFO: You probably want to fix the path to the cookbooks in this file." if @@verbose
          end
        rescue
          puts "WARNING: Unable to create default #{localconfigpath} - please do it manually." if @@verbose
        end
      end

      def get_defaults
        {
          "nfs" => false,
          "cookbook_path" => '~/Sites/easybib/cookbooks',
          "chef_log_level" => 'debug',
          "additional_json" => '{}',
          "gui" => false
        }
      end

    end
  end
end
