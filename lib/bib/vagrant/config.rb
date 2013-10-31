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
