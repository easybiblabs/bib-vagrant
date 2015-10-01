Vagrant.require_plugin "bib-vagrant"

Vagrant.configure("2") do |config|
  foo = ::Bib::Vagrant::Config.new()
  puts foo.get.inspect
 
  config.vm.box = 'imagineeasy-ubuntu-14.04.3_virtualbox-4.3.26r98988_chef-11.10.4_1'
  config.vm.box_url = 'https://s3.amazonaws.com/easybibdeployment/imagineeasy-ubuntu-14.04.3_virtualbox-4.3.26r98988_chef-11.10.4_1.box'

  config.vm.provision "bib_configure_npm" 

end
