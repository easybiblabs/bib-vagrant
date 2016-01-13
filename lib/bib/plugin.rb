puts 'plugin.rb'

begin
  puts '    reqire bib_vagrant'
  require 'bib_vagrant'
rescue LoadError
  raise 'This is a vagrant plugin, do not use standalone.'
end

fail 'This vagrant plugin needs vagrant 1.2.0+' if Vagrant::VERSION < '1.2.0'

require_relative 'version'
require_relative 'bib_vagrant'

module VagrantPlugins
  module Bib
    module Vagrant
      class Plugin < ::Vagrant.plugin('2')
        name 'bib-vagrant'
        description <<-DESC
        This is a null plugin to get bib::vagrant into vagrant
        DESC
      end
    end
  end
end
