Vagrant.require_plugin "bib-vagrant"

Vagrant.configure("2") do |config|
  foo = ::Bib::Vagrant::Config.new()
  puts foo.get.inspect
  config.vm.box = "precise"
end
