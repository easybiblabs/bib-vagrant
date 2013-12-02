begin
  require "vagrant"
rescue LoadError
  raise "This plugin must be run within Vagrant."
end

require "bib/vagrant/plugin"