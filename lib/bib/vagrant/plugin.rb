begin
  require "vagrant"
rescue LoadError
  raise "This is a vagrant plugin, do not use standalone."
end

if Vagrant::VERSION < "1.2.0"
  raise "This vagrant plugin needs vagrant 1.2.0+"
end

require_relative 'config'
require_relative 'version'

module VagrantPlugins
  module Bib
    module Vagrant
      class Plugin < ::Vagrant.plugin("2")

        name "bib-vagrant"
        description <<-DESC
        This is a fake plugin to get bib::vagrant into vagrant
        DESC

        provisioner(:shell) do
          require 'provisioner'
          Provisioner
        end
      end
    end
  end
end
